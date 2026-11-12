import json
from collections.abc import Mapping, Sequence
from inspect import Parameter, Signature
from typing import Annotated, Any, NoReturn

from app.database.connection import get_session
from fastapi import APIRouter, Body, Depends, HTTPException, Path, Query
from sqlalchemy import text
from sqlalchemy.exc import IntegrityError, OperationalError
from sqlalchemy.ext.asyncio import AsyncSession


async def handle_database_write_error(
    session: AsyncSession,
    exc: IntegrityError | OperationalError,
    *,
    signal_status_code: int,
    signal_detail: str | None,
    check_constraint_detail: str,
) -> NoReturn:
    await session.rollback()
    if isinstance(exc, IntegrityError):
        raise HTTPException(
            status_code=409,
            detail="Dữ liệu xung đột với ràng buộc trong cơ sở dữ liệu",
        ) from exc

    error_args = getattr(exc.orig, "args", ())
    error_code = error_args[0] if error_args else None
    if error_code == 1644:
        detail = signal_detail or (
            str(error_args[1])
            if len(error_args) > 1
            else "Dữ liệu vi phạm quy tắc nghiệp vụ."
        )
        raise HTTPException(status_code=signal_status_code, detail=detail) from exc
    if error_code == 3819:
        raise HTTPException(status_code=422, detail=check_constraint_detail) from exc
    raise exc


async def execute_write(
    session: AsyncSession,
    statement: str,
    parameters: dict[str, Any],
    *,
    signal_status_code: int = 409,
    signal_detail: str | None = None,
    check_constraint_detail: str = (
        "Dữ liệu không hợp lệ do vi phạm ràng buộc CHECK của bảng."
    ),
) -> None:
    try:
        await session.execute(text(statement), parameters)
        await session.commit()
    except (IntegrityError, OperationalError) as exc:
        await handle_database_write_error(
            session,
            exc,
            signal_status_code=signal_status_code,
            signal_detail=signal_detail,
            check_constraint_detail=check_constraint_detail,
        )


async def execute_procedure_with_rows(
    session: AsyncSession,
    procedure_call: str,
    parameters: dict[str, Any],
    *,
    signal_status_code: int = 422,
) -> list[dict[str, Any]]:
    try:
        result = await session.execute(text(procedure_call), parameters)
        rows = [dict(row) for row in result.mappings().all()]
        await session.commit()
        return rows
    except (IntegrityError, OperationalError) as exc:
        await handle_database_write_error(
            session,
            exc,
            signal_status_code=signal_status_code,
            signal_detail=None,
            check_constraint_detail=(
                "Tham số không hợp lệ theo ràng buộc trong cơ sở dữ liệu."
            ),
        )


def error_response(description: str) -> dict[str, Any]:
    return {"description": description}


def register_crud_routes(
    router: APIRouter,
    *,
    table: str,
    columns: Sequence[str],
    primary_keys: Sequence[str],
    required_columns: Sequence[str],
    search_columns: Sequence[str],
    search_value_placeholders: Mapping[str, str],
    create_example: dict[str, Any],
    update_example: dict[str, Any],
    generated_columns: Sequence[str] = (),
    time_columns: Sequence[str] = (),
    foreign_keys: Mapping[str, tuple[str, str]] | None = None,
    check_constraint_detail: str | None = None,
    business_conflict_detail: str | None = None,
    delete_procedure: str | None = None,
    allow_create: bool = True,
    path_parameter_descriptions: Mapping[str, str] | None = None,
    path: str = "",
) -> None:
    generated_column_names = set(generated_columns)
    allowed_columns = set(columns) - generated_column_names
    key_columns = tuple(primary_keys)
    if not generated_column_names <= set(columns):
        raise ValueError("generated_columns must be included in columns")
    if not set(required_columns) <= allowed_columns:
        raise ValueError("required_columns must only contain writable columns")
    if not set(key_columns) <= set(columns):
        raise ValueError("primary_keys must be included in columns")
    if not set(search_columns) <= set(columns):
        raise ValueError("search_columns must be included in columns")
    if delete_procedure and len(key_columns) != 1:
        raise ValueError("delete_procedure requires a single-column primary key")
    quoted_table = f"`{table}`"
    time_column_names = set(time_columns)
    selected_columns = ", ".join(
        (
            f"TIME_FORMAT(`{column}`, '%H:%i:%s') AS `{column}`"
            if column in time_column_names
            else f"`{column}`"
        )
        for column in columns
    )
    check_constraint_detail = check_constraint_detail or (
        "Dữ liệu không hợp lệ do vi phạm ràng buộc CHECK của bảng."
    )
    conflict_description = (
        "Dữ liệu vi phạm ràng buộc cơ sở dữ liệu, ví dụ khóa trùng hoặc khóa ngoại."
    )
    if business_conflict_detail:
        conflict_description += f" {business_conflict_detail}"

    def key_filter() -> str:
        return " AND ".join(f"`{column}` = :{column}" for column in key_columns)

    def get_path() -> str:
        if len(key_columns) == 1:
            return f"{path}/{{record_id}}"
        placeholders = "/".join(f"{{{column}}}" for column in key_columns)
        return f"{path}/key/{placeholders}"

    def path_parameter_names() -> tuple[str, ...]:
        if len(key_columns) == 1:
            return ("record_id",)
        return key_columns

    def set_path_signature(endpoint, *, include_payload: bool = False) -> None:
        parameters = [
            Parameter(
                name,
                Parameter.POSITIONAL_OR_KEYWORD,
                annotation=(
                    Annotated[str, Path(description=path_parameter_descriptions[name])]
                    if path_parameter_descriptions and name in path_parameter_descriptions
                    else str
                ),
            )
            for name in path_parameter_names()
        ]
        if include_payload:
            parameters.append(
                Parameter(
                    "payload",
                    Parameter.POSITIONAL_OR_KEYWORD,
                    default=Body(
                        ...,
                        json_schema_extra={"example": update_example},
                        description=(
                            "Chỉ gửi các trường cần cập nhật. "
                            f"Mẫu dữ liệu: `{json.dumps(update_example, ensure_ascii=False)}`"
                        ),
                    ),
                    annotation=dict[str, Any],
                )
            )
        parameters.append(
            Parameter(
                "session",
                Parameter.POSITIONAL_OR_KEYWORD,
                default=Depends(get_session),
                annotation=AsyncSession,
            )
        )
        endpoint.__signature__ = Signature(parameters)

    def record_keys(path_values: dict[str, Any]) -> dict[str, Any]:
        if len(key_columns) == 1:
            return {key_columns[0]: path_values["record_id"]}
        return {column: path_values[column] for column in key_columns}

    async def get_record(session: AsyncSession, keys: dict[str, Any]) -> dict[str, Any]:
        result = await session.execute(
            text(
                f"SELECT {selected_columns} FROM {quoted_table} "
                f"WHERE {key_filter()}"
            ),
            keys,
        )
        record = result.mappings().first()
        if record is None:
            raise HTTPException(status_code=404, detail="Không tìm thấy dữ liệu")
        return dict(record)

    async def validate_foreign_keys(
        session: AsyncSession,
        payload: Mapping[str, Any],
    ) -> None:
        for column, (referenced_table, referenced_column) in (foreign_keys or {}).items():
            value = payload.get(column)
            if value is None:
                continue
            reference = await session.execute(
                text(
                    f"SELECT 1 FROM `{referenced_table}` "
                    f"WHERE `{referenced_column}` = :value LIMIT 1"
                ),
                {"value": value},
            )
            if reference.scalar_one_or_none() is None:
                raise HTTPException(
                    status_code=422,
                    detail=(
                        f"{column} '{value}' không tồn tại trong "
                        f"{referenced_table}.{referenced_column}"
                    ),
                )

    async def list_records(
        session: Annotated[AsyncSession, Depends(get_session)],
    ):
        result = await session.execute(
            text(f"SELECT {selected_columns} FROM {quoted_table}")
        )
        return result.mappings().all()

    async def search_records(
        column: Annotated[
            str,
            Query(
                json_schema_extra={"enum": list(search_columns)},
                description="Chọn cột cần tìm kiếm.",
            ),
        ],
        value: Annotated[
            str,
            Query(
                description=(
                    "Nhập giá trị cần tìm trong cột đã chọn. "
                    "Ví dụ theo cột: "
                    + "; ".join(
                        f"{column}: {search_value_placeholders[column]}"
                        for column in search_columns
                    )
                    + "."
                ),
            ),
        ],
        session: Annotated[AsyncSession, Depends(get_session)],
    ):
        if column not in search_columns:
            raise HTTPException(
                status_code=422,
                detail=f"Cột tìm kiếm không hợp lệ. Chọn một trong: {', '.join(search_columns)}",
            )
        result = await session.execute(
            text(
                f"SELECT {selected_columns} FROM {quoted_table} "
                f"WHERE CAST(`{column}` AS CHAR) LIKE :search_value"
            ),
            {"search_value": f"%{value}%"},
        )
        return result.mappings().all()

    async def create_record(
        payload: Annotated[
            dict[str, Any],
            Body(
                json_schema_extra={"example": create_example},
                description=(
                    f"Gửi JSON để tạo bản ghi trong bảng {table}. "
                    f"Mẫu dữ liệu: `{json.dumps(create_example, ensure_ascii=False)}`"
                ),
            ),
        ],
        session: Annotated[AsyncSession, Depends(get_session)],
    ):
        if not payload:
            raise HTTPException(status_code=400, detail="Dữ liệu không được để trống")
        unknown_columns = set(payload) - allowed_columns
        if unknown_columns:
            raise HTTPException(
                status_code=400,
                detail=f"Cột không hợp lệ: {', '.join(sorted(unknown_columns))}",
            )
        missing_columns = set(required_columns) - set(payload)
        if missing_columns:
            raise HTTPException(
                status_code=422,
                detail=f"Thiếu cột bắt buộc: {', '.join(sorted(missing_columns))}",
            )
        await validate_foreign_keys(session, payload)

        columns_sql = ", ".join(f"`{column}`" for column in payload)
        values_sql = ", ".join(f":{column}" for column in payload)
        await execute_write(
            session,
            f"INSERT INTO {quoted_table} ({columns_sql}) VALUES ({values_sql})",
            payload,
            signal_detail=business_conflict_detail,
            check_constraint_detail=check_constraint_detail,
        )
        keys = {column: payload[column] for column in key_columns}
        return await get_record(session, keys)

    async def update_record(**kwargs: Any):
        payload = kwargs["payload"]
        session = kwargs["session"]
        if not payload:
            raise HTTPException(status_code=400, detail="Dữ liệu cập nhật không được để trống")
        unknown_columns = set(payload) - allowed_columns
        if unknown_columns:
            raise HTTPException(
                status_code=400,
                detail=f"Cột không hợp lệ: {', '.join(sorted(unknown_columns))}",
            )
        immutable_columns = set(key_columns) & set(payload)
        if immutable_columns:
            raise HTTPException(
                status_code=400,
                detail=f"Không thể cập nhật khóa chính: {', '.join(sorted(immutable_columns))}",
            )
        await validate_foreign_keys(session, payload)

        keys = record_keys(kwargs)
        await get_record(session, keys)
        assignments = ", ".join(f"`{column}` = :value_{column}" for column in payload)
        parameters = {f"value_{column}": value for column, value in payload.items()}
        parameters.update(keys)
        await execute_write(
            session,
            f"UPDATE {quoted_table} SET {assignments} WHERE {key_filter()}",
            parameters,
            signal_detail=business_conflict_detail,
            check_constraint_detail=check_constraint_detail,
        )
        return await get_record(session, keys)

    async def delete_record(**kwargs: Any):
        session = kwargs["session"]
        keys = record_keys(kwargs)
        await get_record(session, keys)
        statement = (
            f"CALL `{delete_procedure}`(:{key_columns[0]})"
            if delete_procedure
            else f"DELETE FROM {quoted_table} WHERE {key_filter()}"
        )
        await execute_write(
            session,
            statement,
            keys,
            signal_detail=business_conflict_detail,
            check_constraint_detail=check_constraint_detail,
        )
        return {"message": "Xóa dữ liệu thành công"}

    async def get_single_record(**kwargs: Any):
        session = kwargs["session"]
        keys = record_keys(kwargs)
        return await get_record(session, keys)

    list_records.__name__ = f"list_{table}"
    search_records.__name__ = f"search_{table}"
    create_record.__name__ = f"create_{table}"
    update_record.__name__ = f"update_{table}"
    delete_record.__name__ = f"delete_{table}"
    get_single_record.__name__ = f"get_{table}"
    set_path_signature(get_single_record)
    set_path_signature(update_record, include_payload=True)
    set_path_signature(delete_record)

    router.add_api_route(
        path or "/",
        list_records,
        methods=["GET"],
        responses={
            500: error_response("Lỗi máy chủ khi truy vấn cơ sở dữ liệu."),
        },
    )
    router.add_api_route(
        f"{path}/search",
        search_records,
        methods=["GET"],
        responses={
            422: error_response(
                "Thiếu hoặc sai tham số tìm kiếm; column phải là một cột được hỗ trợ."
            ),
            500: error_response("Lỗi máy chủ khi truy vấn cơ sở dữ liệu."),
        },
    )
    if allow_create:
        router.add_api_route(
            path or "/",
            create_record,
            methods=["POST"],
            responses={
                400: error_response("Body rỗng hoặc chứa cột không hợp lệ."),
                409: error_response(conflict_description),
                422: error_response(
                    "Thiếu trường bắt buộc, sai định dạng body, mã tham chiếu không tồn tại "
                    f"hoặc {check_constraint_detail}"
                ),
                500: error_response("Lỗi máy chủ khi tạo dữ liệu."),
            },
        )
    item_path = get_path()
    router.add_api_route(
        item_path,
        get_single_record,
        methods=["GET"],
        responses={
            404: error_response("Không tìm thấy bản ghi theo khóa đã cung cấp."),
            500: error_response("Lỗi máy chủ khi truy vấn cơ sở dữ liệu."),
        },
    )
    router.add_api_route(
        item_path,
        update_record,
        methods=["PUT"],
        operation_id=f"update_{table}_put",
        responses={
            400: error_response(
                "Body rỗng, chứa cột không hợp lệ hoặc cố thay đổi khóa chính."
            ),
            404: error_response("Không tìm thấy bản ghi theo khóa đã cung cấp."),
            409: error_response(conflict_description),
            422: error_response(
                "Sai định dạng body, giá trị khóa ngoại không tồn tại "
                f"hoặc {check_constraint_detail}"
            ),
            500: error_response("Lỗi máy chủ khi cập nhật dữ liệu."),
        },
    )
    router.add_api_route(
        item_path,
        delete_record,
        methods=["DELETE"],
        responses={
            404: error_response("Không tìm thấy bản ghi theo khóa đã cung cấp."),
            409: error_response(
                "Không thể xóa do xung đột với ràng buộc trong cơ sở dữ liệu."
            ),
            500: error_response("Lỗi máy chủ khi xóa dữ liệu."),
        },
    )
