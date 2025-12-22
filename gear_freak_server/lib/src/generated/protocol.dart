/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import 'package:serverpod/protocol.dart' as _i2;
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as _i3;
import 'feature/chat/model/dto/paginated_chat_messages_response.dto.dart'
    as _i4;
import 'common/s3/model/dto/generate_presigned_upload_url_request.dto.dart'
    as _i5;
import 'common/s3/model/dto/generate_presigned_upload_url_response.dto.dart'
    as _i6;
import 'feature/auth/model/dto/kakao_auth_response.dto.dart' as _i7;
import 'feature/chat/model/chat_message.dart' as _i8;
import 'feature/chat/model/chat_participant.dart' as _i9;
import 'feature/chat/model/chat_room.dart' as _i10;
import 'feature/chat/model/dto/chat_message_response.dto.dart' as _i11;
import 'feature/chat/model/dto/chat_participant_info.dto.dart' as _i12;
import 'feature/chat/model/dto/create_chat_room_request.dto.dart' as _i13;
import 'feature/chat/model/dto/create_chat_room_response.dto.dart' as _i14;
import 'feature/chat/model/dto/get_chat_messages_request.dto.dart' as _i15;
import 'feature/chat/model/dto/join_chat_room_request.dto.dart' as _i16;
import 'feature/chat/model/dto/join_chat_room_response.dto.dart' as _i17;
import 'feature/chat/model/dto/leave_chat_room_request.dto.dart' as _i18;
import 'feature/chat/model/dto/leave_chat_room_response.dto.dart' as _i19;
import 'common/model/pagination_dto.dart' as _i20;
import 'feature/chat/model/dto/paginated_chat_rooms_response.dto.dart' as _i21;
import 'feature/chat/model/dto/send_message_request.dto.dart' as _i22;
import 'feature/chat/model/dto/update_chat_room_notification_request.dto.dart'
    as _i23;
import 'feature/chat/model/enum/chat_room_type.dart' as _i24;
import 'feature/chat/model/enum/message_type.dart' as _i25;
import 'feature/notification/model/dto/notification_list_response.dto.dart'
    as _i26;
import 'feature/notification/model/dto/notification_response.dto.dart' as _i27;
import 'feature/notification/model/notification.dart' as _i28;
import 'feature/notification/model/notification_type.dart' as _i29;
import 'feature/product/model/dto/create_product_request.dto.dart' as _i30;
import 'feature/product/model/dto/paginated_products_response.dto.dart' as _i31;
import 'feature/product/model/dto/product_stats.dto.dart' as _i32;
import 'feature/product/model/dto/update_product_request.dto.dart' as _i33;
import 'greeting.dart' as _i34;
import 'feature/product/model/favorite.dart' as _i35;
import 'feature/product/model/product.dart' as _i36;
import 'feature/product/model/product_category.dart' as _i37;
import 'feature/product/model/product_condition.dart' as _i38;
import 'feature/product/model/product_sort_by.dart' as _i39;
import 'feature/product/model/product_status.dart' as _i40;
import 'feature/product/model/trade_method.dart' as _i41;
import 'feature/review/model/dto/create_transaction_review_request.dto.dart'
    as _i42;
import 'feature/review/model/dto/transaction_review_list_response.dto.dart'
    as _i43;
import 'feature/review/model/dto/transaction_review_response.dto.dart' as _i44;
import 'feature/review/model/review_type.dart' as _i45;
import 'feature/review/model/transaction_review.dart' as _i46;
import 'feature/user/model/dto/update_user_profile_request.dto.dart' as _i47;
import 'feature/user/model/fcm_token.dart' as _i48;
import 'feature/user/model/user.dart' as _i49;
import 'feature/product/model/dto/update_product_status_request.dto.dart'
    as _i50;
import 'package:gear_freak_server/src/generated/feature/chat/model/chat_room.dart'
    as _i51;
import 'package:gear_freak_server/src/generated/feature/chat/model/dto/chat_participant_info.dto.dart'
    as _i52;
export 'common/model/pagination_dto.dart';
export 'common/s3/model/dto/generate_presigned_upload_url_request.dto.dart';
export 'common/s3/model/dto/generate_presigned_upload_url_response.dto.dart';
export 'feature/auth/model/dto/kakao_auth_response.dto.dart';
export 'feature/chat/model/chat_message.dart';
export 'feature/chat/model/chat_participant.dart';
export 'feature/chat/model/chat_room.dart';
export 'feature/chat/model/dto/chat_message_response.dto.dart';
export 'feature/chat/model/dto/chat_participant_info.dto.dart';
export 'feature/chat/model/dto/create_chat_room_request.dto.dart';
export 'feature/chat/model/dto/create_chat_room_response.dto.dart';
export 'feature/chat/model/dto/get_chat_messages_request.dto.dart';
export 'feature/chat/model/dto/join_chat_room_request.dto.dart';
export 'feature/chat/model/dto/join_chat_room_response.dto.dart';
export 'feature/chat/model/dto/leave_chat_room_request.dto.dart';
export 'feature/chat/model/dto/leave_chat_room_response.dto.dart';
export 'feature/chat/model/dto/paginated_chat_messages_response.dto.dart';
export 'feature/chat/model/dto/paginated_chat_rooms_response.dto.dart';
export 'feature/chat/model/dto/send_message_request.dto.dart';
export 'feature/chat/model/dto/update_chat_room_notification_request.dto.dart';
export 'feature/chat/model/enum/chat_room_type.dart';
export 'feature/chat/model/enum/message_type.dart';
export 'feature/notification/model/dto/notification_list_response.dto.dart';
export 'feature/notification/model/dto/notification_response.dto.dart';
export 'feature/notification/model/notification.dart';
export 'feature/notification/model/notification_type.dart';
export 'feature/product/model/dto/create_product_request.dto.dart';
export 'feature/product/model/dto/paginated_products_response.dto.dart';
export 'feature/product/model/dto/product_stats.dto.dart';
export 'feature/product/model/dto/update_product_request.dto.dart';
export 'feature/product/model/dto/update_product_status_request.dto.dart';
export 'feature/product/model/favorite.dart';
export 'feature/product/model/product.dart';
export 'feature/product/model/product_category.dart';
export 'feature/product/model/product_condition.dart';
export 'feature/product/model/product_sort_by.dart';
export 'feature/product/model/product_status.dart';
export 'feature/product/model/trade_method.dart';
export 'feature/review/model/dto/create_transaction_review_request.dto.dart';
export 'feature/review/model/dto/transaction_review_list_response.dto.dart';
export 'feature/review/model/dto/transaction_review_response.dto.dart';
export 'feature/review/model/review_type.dart';
export 'feature/review/model/transaction_review.dart';
export 'feature/user/model/dto/update_user_profile_request.dto.dart';
export 'feature/user/model/fcm_token.dart';
export 'feature/user/model/user.dart';
export 'greeting.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'chat_message',
      dartName: 'ChatMessage',
      schema: 'public',
      module: 'gear_freak',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'chat_message_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'chatRoomId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'senderId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'content',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'messageType',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'protocol:MessageType',
        ),
        _i2.ColumnDefinition(
          name: 'attachmentUrl',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'attachmentName',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'attachmentSize',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'chat_message_fk_0',
          columns: ['chatRoomId'],
          referenceTable: 'chat_room',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        )
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'chat_message_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'chat_room_messages_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'chatRoomId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'sender_messages_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'senderId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'message_type_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'messageType',
            )
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'chat_participant',
      dartName: 'ChatParticipant',
      schema: 'public',
      module: 'gear_freak',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'chat_participant_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'chatRoomId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'userId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'joinedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'isActive',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'leftAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'lastReadAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'isNotificationEnabled',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'chat_participant_fk_0',
          columns: ['chatRoomId'],
          referenceTable: 'chat_room',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'chat_participant_fk_1',
          columns: ['userId'],
          referenceTable: 'user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'chat_participant_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'unique_chat_participant_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'chatRoomId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'active_participants_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'chatRoomId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'isActive',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'user_participations_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'isActive',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'chat_room',
      dartName: 'ChatRoom',
      schema: 'public',
      module: 'gear_freak',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'chat_room_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'productId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'title',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'chatRoomType',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'protocol:ChatRoomType',
        ),
        _i2.ColumnDefinition(
          name: 'participantCount',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'lastActivityAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'unreadCount',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'chat_room_fk_0',
          columns: ['productId'],
          referenceTable: 'product',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        )
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'chat_room_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'product_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'productId',
            )
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'last_activity_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'lastActivityAt',
            )
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'chat_room_type_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'chatRoomType',
            )
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'favorite',
      dartName: 'Favorite',
      schema: 'public',
      module: 'gear_freak',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'favorite_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'userId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'productId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'favorite_fk_0',
          columns: ['userId'],
          referenceTable: 'user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'favorite_fk_1',
          columns: ['productId'],
          referenceTable: 'product',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'favorite_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'user_product_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'productId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'fcm_token',
      dartName: 'FcmToken',
      schema: 'public',
      module: 'gear_freak',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'fcm_token_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'userId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'token',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'deviceType',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'fcm_token_fk_0',
          columns: ['userId'],
          referenceTable: 'user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        )
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'fcm_token_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'user_id_token_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'token',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'user_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'userId',
            )
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'notification',
      dartName: 'Notification',
      schema: 'public',
      module: 'gear_freak',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'notification_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'userId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'notificationType',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'protocol:NotificationType',
        ),
        _i2.ColumnDefinition(
          name: 'title',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'body',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'data',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'isRead',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'readAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'notification_fk_0',
          columns: ['userId'],
          referenceTable: 'user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        )
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'notification_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'user_notifications_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'user_unread_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'isRead',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'notification_type_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'notificationType',
            )
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'product',
      dartName: 'Product',
      schema: 'public',
      module: 'gear_freak',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'product_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'sellerId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'title',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'category',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'protocol:ProductCategory',
        ),
        _i2.ColumnDefinition(
          name: 'price',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'condition',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'protocol:ProductCondition',
        ),
        _i2.ColumnDefinition(
          name: 'description',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'tradeMethod',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'protocol:TradeMethod',
        ),
        _i2.ColumnDefinition(
          name: 'baseAddress',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'detailAddress',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'imageUrls',
          columnType: _i2.ColumnType.json,
          isNullable: true,
          dartType: 'List<String>?',
        ),
        _i2.ColumnDefinition(
          name: 'viewCount',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'favoriteCount',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'chatCount',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'status',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'protocol:ProductStatus?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'product_fk_0',
          columns: ['sellerId'],
          referenceTable: 'user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        )
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'product_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'seller_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'sellerId',
            )
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'category_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'category',
            )
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'created_at_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'createdAt',
            )
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'transaction_review',
      dartName: 'TransactionReview',
      schema: 'public',
      module: 'gear_freak',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'transaction_review_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'productId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'chatRoomId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'reviewerId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'revieweeId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'rating',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'content',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'reviewType',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'protocol:ReviewType',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'transaction_review_fk_0',
          columns: ['productId'],
          referenceTable: 'product',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'transaction_review_fk_1',
          columns: ['chatRoomId'],
          referenceTable: 'chat_room',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'transaction_review_fk_2',
          columns: ['reviewerId'],
          referenceTable: 'user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'transaction_review_fk_3',
          columns: ['revieweeId'],
          referenceTable: 'user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'transaction_review_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'unique_review_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'productId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'chatRoomId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'reviewerId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'reviewType',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'product_reviews_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'productId',
            )
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'reviewee_reviews_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'revieweeId',
            )
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'reviewer_reviews_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'reviewerId',
            )
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'review_created_at_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'createdAt',
            )
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'user',
      dartName: 'User',
      schema: 'public',
      module: 'gear_freak',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'user_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'userInfoId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'nickname',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'profileImageUrl',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'bio',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'withdrawalDate',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'blockedReason',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'blockedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'lastLoginAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'user_fk_0',
          columns: ['userInfoId'],
          referenceTable: 'serverpod_user_info',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        )
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'user_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'user_info_id_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'userInfoId',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._i3.Protocol.targetTableDefinitions,
    ..._i2.Protocol.targetTableDefinitions,
  ];

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (t == _i4.PaginatedChatMessagesResponseDto) {
      return _i4.PaginatedChatMessagesResponseDto.fromJson(data) as T;
    }
    if (t == _i5.GeneratePresignedUploadUrlRequestDto) {
      return _i5.GeneratePresignedUploadUrlRequestDto.fromJson(data) as T;
    }
    if (t == _i6.GeneratePresignedUploadUrlResponseDto) {
      return _i6.GeneratePresignedUploadUrlResponseDto.fromJson(data) as T;
    }
    if (t == _i7.KakaoAuthResponseDto) {
      return _i7.KakaoAuthResponseDto.fromJson(data) as T;
    }
    if (t == _i8.ChatMessage) {
      return _i8.ChatMessage.fromJson(data) as T;
    }
    if (t == _i9.ChatParticipant) {
      return _i9.ChatParticipant.fromJson(data) as T;
    }
    if (t == _i10.ChatRoom) {
      return _i10.ChatRoom.fromJson(data) as T;
    }
    if (t == _i11.ChatMessageResponseDto) {
      return _i11.ChatMessageResponseDto.fromJson(data) as T;
    }
    if (t == _i12.ChatParticipantInfoDto) {
      return _i12.ChatParticipantInfoDto.fromJson(data) as T;
    }
    if (t == _i13.CreateChatRoomRequestDto) {
      return _i13.CreateChatRoomRequestDto.fromJson(data) as T;
    }
    if (t == _i14.CreateChatRoomResponseDto) {
      return _i14.CreateChatRoomResponseDto.fromJson(data) as T;
    }
    if (t == _i15.GetChatMessagesRequestDto) {
      return _i15.GetChatMessagesRequestDto.fromJson(data) as T;
    }
    if (t == _i16.JoinChatRoomRequestDto) {
      return _i16.JoinChatRoomRequestDto.fromJson(data) as T;
    }
    if (t == _i17.JoinChatRoomResponseDto) {
      return _i17.JoinChatRoomResponseDto.fromJson(data) as T;
    }
    if (t == _i18.LeaveChatRoomRequestDto) {
      return _i18.LeaveChatRoomRequestDto.fromJson(data) as T;
    }
    if (t == _i19.LeaveChatRoomResponseDto) {
      return _i19.LeaveChatRoomResponseDto.fromJson(data) as T;
    }
    if (t == _i20.PaginationDto) {
      return _i20.PaginationDto.fromJson(data) as T;
    }
    if (t == _i21.PaginatedChatRoomsResponseDto) {
      return _i21.PaginatedChatRoomsResponseDto.fromJson(data) as T;
    }
    if (t == _i22.SendMessageRequestDto) {
      return _i22.SendMessageRequestDto.fromJson(data) as T;
    }
    if (t == _i23.UpdateChatRoomNotificationRequestDto) {
      return _i23.UpdateChatRoomNotificationRequestDto.fromJson(data) as T;
    }
    if (t == _i24.ChatRoomType) {
      return _i24.ChatRoomType.fromJson(data) as T;
    }
    if (t == _i25.MessageType) {
      return _i25.MessageType.fromJson(data) as T;
    }
    if (t == _i26.NotificationListResponseDto) {
      return _i26.NotificationListResponseDto.fromJson(data) as T;
    }
    if (t == _i27.NotificationResponseDto) {
      return _i27.NotificationResponseDto.fromJson(data) as T;
    }
    if (t == _i28.Notification) {
      return _i28.Notification.fromJson(data) as T;
    }
    if (t == _i29.NotificationType) {
      return _i29.NotificationType.fromJson(data) as T;
    }
    if (t == _i30.CreateProductRequestDto) {
      return _i30.CreateProductRequestDto.fromJson(data) as T;
    }
    if (t == _i31.PaginatedProductsResponseDto) {
      return _i31.PaginatedProductsResponseDto.fromJson(data) as T;
    }
    if (t == _i32.ProductStatsDto) {
      return _i32.ProductStatsDto.fromJson(data) as T;
    }
    if (t == _i33.UpdateProductRequestDto) {
      return _i33.UpdateProductRequestDto.fromJson(data) as T;
    }
    if (t == _i34.Greeting) {
      return _i34.Greeting.fromJson(data) as T;
    }
    if (t == _i35.Favorite) {
      return _i35.Favorite.fromJson(data) as T;
    }
    if (t == _i36.Product) {
      return _i36.Product.fromJson(data) as T;
    }
    if (t == _i37.ProductCategory) {
      return _i37.ProductCategory.fromJson(data) as T;
    }
    if (t == _i38.ProductCondition) {
      return _i38.ProductCondition.fromJson(data) as T;
    }
    if (t == _i39.ProductSortBy) {
      return _i39.ProductSortBy.fromJson(data) as T;
    }
    if (t == _i40.ProductStatus) {
      return _i40.ProductStatus.fromJson(data) as T;
    }
    if (t == _i41.TradeMethod) {
      return _i41.TradeMethod.fromJson(data) as T;
    }
    if (t == _i42.CreateTransactionReviewRequestDto) {
      return _i42.CreateTransactionReviewRequestDto.fromJson(data) as T;
    }
    if (t == _i43.TransactionReviewListResponseDto) {
      return _i43.TransactionReviewListResponseDto.fromJson(data) as T;
    }
    if (t == _i44.TransactionReviewResponseDto) {
      return _i44.TransactionReviewResponseDto.fromJson(data) as T;
    }
    if (t == _i45.ReviewType) {
      return _i45.ReviewType.fromJson(data) as T;
    }
    if (t == _i46.TransactionReview) {
      return _i46.TransactionReview.fromJson(data) as T;
    }
    if (t == _i47.UpdateUserProfileRequestDto) {
      return _i47.UpdateUserProfileRequestDto.fromJson(data) as T;
    }
    if (t == _i48.FcmToken) {
      return _i48.FcmToken.fromJson(data) as T;
    }
    if (t == _i49.User) {
      return _i49.User.fromJson(data) as T;
    }
    if (t == _i50.UpdateProductStatusRequestDto) {
      return _i50.UpdateProductStatusRequestDto.fromJson(data) as T;
    }
    if (t == _i1.getType<_i4.PaginatedChatMessagesResponseDto?>()) {
      return (data != null
          ? _i4.PaginatedChatMessagesResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i5.GeneratePresignedUploadUrlRequestDto?>()) {
      return (data != null
          ? _i5.GeneratePresignedUploadUrlRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i6.GeneratePresignedUploadUrlResponseDto?>()) {
      return (data != null
          ? _i6.GeneratePresignedUploadUrlResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i7.KakaoAuthResponseDto?>()) {
      return (data != null ? _i7.KakaoAuthResponseDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i8.ChatMessage?>()) {
      return (data != null ? _i8.ChatMessage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.ChatParticipant?>()) {
      return (data != null ? _i9.ChatParticipant.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.ChatRoom?>()) {
      return (data != null ? _i10.ChatRoom.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.ChatMessageResponseDto?>()) {
      return (data != null ? _i11.ChatMessageResponseDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i12.ChatParticipantInfoDto?>()) {
      return (data != null ? _i12.ChatParticipantInfoDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i13.CreateChatRoomRequestDto?>()) {
      return (data != null
          ? _i13.CreateChatRoomRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i14.CreateChatRoomResponseDto?>()) {
      return (data != null
          ? _i14.CreateChatRoomResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i15.GetChatMessagesRequestDto?>()) {
      return (data != null
          ? _i15.GetChatMessagesRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i16.JoinChatRoomRequestDto?>()) {
      return (data != null ? _i16.JoinChatRoomRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i17.JoinChatRoomResponseDto?>()) {
      return (data != null ? _i17.JoinChatRoomResponseDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i18.LeaveChatRoomRequestDto?>()) {
      return (data != null ? _i18.LeaveChatRoomRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i19.LeaveChatRoomResponseDto?>()) {
      return (data != null
          ? _i19.LeaveChatRoomResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i20.PaginationDto?>()) {
      return (data != null ? _i20.PaginationDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.PaginatedChatRoomsResponseDto?>()) {
      return (data != null
          ? _i21.PaginatedChatRoomsResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i22.SendMessageRequestDto?>()) {
      return (data != null ? _i22.SendMessageRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i23.UpdateChatRoomNotificationRequestDto?>()) {
      return (data != null
          ? _i23.UpdateChatRoomNotificationRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i24.ChatRoomType?>()) {
      return (data != null ? _i24.ChatRoomType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i25.MessageType?>()) {
      return (data != null ? _i25.MessageType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i26.NotificationListResponseDto?>()) {
      return (data != null
          ? _i26.NotificationListResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i27.NotificationResponseDto?>()) {
      return (data != null ? _i27.NotificationResponseDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i28.Notification?>()) {
      return (data != null ? _i28.Notification.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i29.NotificationType?>()) {
      return (data != null ? _i29.NotificationType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i30.CreateProductRequestDto?>()) {
      return (data != null ? _i30.CreateProductRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i31.PaginatedProductsResponseDto?>()) {
      return (data != null
          ? _i31.PaginatedProductsResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i32.ProductStatsDto?>()) {
      return (data != null ? _i32.ProductStatsDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i33.UpdateProductRequestDto?>()) {
      return (data != null ? _i33.UpdateProductRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i34.Greeting?>()) {
      return (data != null ? _i34.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i35.Favorite?>()) {
      return (data != null ? _i35.Favorite.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.Product?>()) {
      return (data != null ? _i36.Product.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i37.ProductCategory?>()) {
      return (data != null ? _i37.ProductCategory.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i38.ProductCondition?>()) {
      return (data != null ? _i38.ProductCondition.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i39.ProductSortBy?>()) {
      return (data != null ? _i39.ProductSortBy.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i40.ProductStatus?>()) {
      return (data != null ? _i40.ProductStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i41.TradeMethod?>()) {
      return (data != null ? _i41.TradeMethod.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i42.CreateTransactionReviewRequestDto?>()) {
      return (data != null
          ? _i42.CreateTransactionReviewRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i43.TransactionReviewListResponseDto?>()) {
      return (data != null
          ? _i43.TransactionReviewListResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i44.TransactionReviewResponseDto?>()) {
      return (data != null
          ? _i44.TransactionReviewResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i45.ReviewType?>()) {
      return (data != null ? _i45.ReviewType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i46.TransactionReview?>()) {
      return (data != null ? _i46.TransactionReview.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i47.UpdateUserProfileRequestDto?>()) {
      return (data != null
          ? _i47.UpdateUserProfileRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i48.FcmToken?>()) {
      return (data != null ? _i48.FcmToken.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i49.User?>()) {
      return (data != null ? _i49.User.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i50.UpdateProductStatusRequestDto?>()) {
      return (data != null
          ? _i50.UpdateProductStatusRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == List<_i11.ChatMessageResponseDto>) {
      return (data as List)
          .map((e) => deserialize<_i11.ChatMessageResponseDto>(e))
          .toList() as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<String>(e)).toList()
          : null) as T;
    }
    if (t == List<_i10.ChatRoom>) {
      return (data as List).map((e) => deserialize<_i10.ChatRoom>(e)).toList()
          as T;
    }
    if (t == List<_i27.NotificationResponseDto>) {
      return (data as List)
          .map((e) => deserialize<_i27.NotificationResponseDto>(e))
          .toList() as T;
    }
    if (t == _i1.getType<Map<String, String>?>()) {
      return (data != null
          ? (data as Map).map((k, v) =>
              MapEntry(deserialize<String>(k), deserialize<String>(v)))
          : null) as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<String>(e)).toList()
          : null) as T;
    }
    if (t == List<_i36.Product>) {
      return (data as List).map((e) => deserialize<_i36.Product>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<String>(e)).toList()
          : null) as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<String>(e)).toList()
          : null) as T;
    }
    if (t == List<_i44.TransactionReviewResponseDto>) {
      return (data as List)
          .map((e) => deserialize<_i44.TransactionReviewResponseDto>(e))
          .toList() as T;
    }
    if (t == _i1.getType<List<_i51.ChatRoom>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<_i51.ChatRoom>(e)).toList()
          : null) as T;
    }
    if (t == List<_i52.ChatParticipantInfoDto>) {
      return (data as List)
          .map((e) => deserialize<_i52.ChatParticipantInfoDto>(e))
          .toList() as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    try {
      return _i3.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i4.PaginatedChatMessagesResponseDto) {
      return 'PaginatedChatMessagesResponseDto';
    }
    if (data is _i5.GeneratePresignedUploadUrlRequestDto) {
      return 'GeneratePresignedUploadUrlRequestDto';
    }
    if (data is _i6.GeneratePresignedUploadUrlResponseDto) {
      return 'GeneratePresignedUploadUrlResponseDto';
    }
    if (data is _i7.KakaoAuthResponseDto) {
      return 'KakaoAuthResponseDto';
    }
    if (data is _i8.ChatMessage) {
      return 'ChatMessage';
    }
    if (data is _i9.ChatParticipant) {
      return 'ChatParticipant';
    }
    if (data is _i10.ChatRoom) {
      return 'ChatRoom';
    }
    if (data is _i11.ChatMessageResponseDto) {
      return 'ChatMessageResponseDto';
    }
    if (data is _i12.ChatParticipantInfoDto) {
      return 'ChatParticipantInfoDto';
    }
    if (data is _i13.CreateChatRoomRequestDto) {
      return 'CreateChatRoomRequestDto';
    }
    if (data is _i14.CreateChatRoomResponseDto) {
      return 'CreateChatRoomResponseDto';
    }
    if (data is _i15.GetChatMessagesRequestDto) {
      return 'GetChatMessagesRequestDto';
    }
    if (data is _i16.JoinChatRoomRequestDto) {
      return 'JoinChatRoomRequestDto';
    }
    if (data is _i17.JoinChatRoomResponseDto) {
      return 'JoinChatRoomResponseDto';
    }
    if (data is _i18.LeaveChatRoomRequestDto) {
      return 'LeaveChatRoomRequestDto';
    }
    if (data is _i19.LeaveChatRoomResponseDto) {
      return 'LeaveChatRoomResponseDto';
    }
    if (data is _i20.PaginationDto) {
      return 'PaginationDto';
    }
    if (data is _i21.PaginatedChatRoomsResponseDto) {
      return 'PaginatedChatRoomsResponseDto';
    }
    if (data is _i22.SendMessageRequestDto) {
      return 'SendMessageRequestDto';
    }
    if (data is _i23.UpdateChatRoomNotificationRequestDto) {
      return 'UpdateChatRoomNotificationRequestDto';
    }
    if (data is _i24.ChatRoomType) {
      return 'ChatRoomType';
    }
    if (data is _i25.MessageType) {
      return 'MessageType';
    }
    if (data is _i26.NotificationListResponseDto) {
      return 'NotificationListResponseDto';
    }
    if (data is _i27.NotificationResponseDto) {
      return 'NotificationResponseDto';
    }
    if (data is _i28.Notification) {
      return 'Notification';
    }
    if (data is _i29.NotificationType) {
      return 'NotificationType';
    }
    if (data is _i30.CreateProductRequestDto) {
      return 'CreateProductRequestDto';
    }
    if (data is _i31.PaginatedProductsResponseDto) {
      return 'PaginatedProductsResponseDto';
    }
    if (data is _i32.ProductStatsDto) {
      return 'ProductStatsDto';
    }
    if (data is _i33.UpdateProductRequestDto) {
      return 'UpdateProductRequestDto';
    }
    if (data is _i34.Greeting) {
      return 'Greeting';
    }
    if (data is _i35.Favorite) {
      return 'Favorite';
    }
    if (data is _i36.Product) {
      return 'Product';
    }
    if (data is _i37.ProductCategory) {
      return 'ProductCategory';
    }
    if (data is _i38.ProductCondition) {
      return 'ProductCondition';
    }
    if (data is _i39.ProductSortBy) {
      return 'ProductSortBy';
    }
    if (data is _i40.ProductStatus) {
      return 'ProductStatus';
    }
    if (data is _i41.TradeMethod) {
      return 'TradeMethod';
    }
    if (data is _i42.CreateTransactionReviewRequestDto) {
      return 'CreateTransactionReviewRequestDto';
    }
    if (data is _i43.TransactionReviewListResponseDto) {
      return 'TransactionReviewListResponseDto';
    }
    if (data is _i44.TransactionReviewResponseDto) {
      return 'TransactionReviewResponseDto';
    }
    if (data is _i45.ReviewType) {
      return 'ReviewType';
    }
    if (data is _i46.TransactionReview) {
      return 'TransactionReview';
    }
    if (data is _i47.UpdateUserProfileRequestDto) {
      return 'UpdateUserProfileRequestDto';
    }
    if (data is _i48.FcmToken) {
      return 'FcmToken';
    }
    if (data is _i49.User) {
      return 'User';
    }
    if (data is _i50.UpdateProductStatusRequestDto) {
      return 'UpdateProductStatusRequestDto';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    className = _i3.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'PaginatedChatMessagesResponseDto') {
      return deserialize<_i4.PaginatedChatMessagesResponseDto>(data['data']);
    }
    if (dataClassName == 'GeneratePresignedUploadUrlRequestDto') {
      return deserialize<_i5.GeneratePresignedUploadUrlRequestDto>(
          data['data']);
    }
    if (dataClassName == 'GeneratePresignedUploadUrlResponseDto') {
      return deserialize<_i6.GeneratePresignedUploadUrlResponseDto>(
          data['data']);
    }
    if (dataClassName == 'KakaoAuthResponseDto') {
      return deserialize<_i7.KakaoAuthResponseDto>(data['data']);
    }
    if (dataClassName == 'ChatMessage') {
      return deserialize<_i8.ChatMessage>(data['data']);
    }
    if (dataClassName == 'ChatParticipant') {
      return deserialize<_i9.ChatParticipant>(data['data']);
    }
    if (dataClassName == 'ChatRoom') {
      return deserialize<_i10.ChatRoom>(data['data']);
    }
    if (dataClassName == 'ChatMessageResponseDto') {
      return deserialize<_i11.ChatMessageResponseDto>(data['data']);
    }
    if (dataClassName == 'ChatParticipantInfoDto') {
      return deserialize<_i12.ChatParticipantInfoDto>(data['data']);
    }
    if (dataClassName == 'CreateChatRoomRequestDto') {
      return deserialize<_i13.CreateChatRoomRequestDto>(data['data']);
    }
    if (dataClassName == 'CreateChatRoomResponseDto') {
      return deserialize<_i14.CreateChatRoomResponseDto>(data['data']);
    }
    if (dataClassName == 'GetChatMessagesRequestDto') {
      return deserialize<_i15.GetChatMessagesRequestDto>(data['data']);
    }
    if (dataClassName == 'JoinChatRoomRequestDto') {
      return deserialize<_i16.JoinChatRoomRequestDto>(data['data']);
    }
    if (dataClassName == 'JoinChatRoomResponseDto') {
      return deserialize<_i17.JoinChatRoomResponseDto>(data['data']);
    }
    if (dataClassName == 'LeaveChatRoomRequestDto') {
      return deserialize<_i18.LeaveChatRoomRequestDto>(data['data']);
    }
    if (dataClassName == 'LeaveChatRoomResponseDto') {
      return deserialize<_i19.LeaveChatRoomResponseDto>(data['data']);
    }
    if (dataClassName == 'PaginationDto') {
      return deserialize<_i20.PaginationDto>(data['data']);
    }
    if (dataClassName == 'PaginatedChatRoomsResponseDto') {
      return deserialize<_i21.PaginatedChatRoomsResponseDto>(data['data']);
    }
    if (dataClassName == 'SendMessageRequestDto') {
      return deserialize<_i22.SendMessageRequestDto>(data['data']);
    }
    if (dataClassName == 'UpdateChatRoomNotificationRequestDto') {
      return deserialize<_i23.UpdateChatRoomNotificationRequestDto>(
          data['data']);
    }
    if (dataClassName == 'ChatRoomType') {
      return deserialize<_i24.ChatRoomType>(data['data']);
    }
    if (dataClassName == 'MessageType') {
      return deserialize<_i25.MessageType>(data['data']);
    }
    if (dataClassName == 'NotificationListResponseDto') {
      return deserialize<_i26.NotificationListResponseDto>(data['data']);
    }
    if (dataClassName == 'NotificationResponseDto') {
      return deserialize<_i27.NotificationResponseDto>(data['data']);
    }
    if (dataClassName == 'Notification') {
      return deserialize<_i28.Notification>(data['data']);
    }
    if (dataClassName == 'NotificationType') {
      return deserialize<_i29.NotificationType>(data['data']);
    }
    if (dataClassName == 'CreateProductRequestDto') {
      return deserialize<_i30.CreateProductRequestDto>(data['data']);
    }
    if (dataClassName == 'PaginatedProductsResponseDto') {
      return deserialize<_i31.PaginatedProductsResponseDto>(data['data']);
    }
    if (dataClassName == 'ProductStatsDto') {
      return deserialize<_i32.ProductStatsDto>(data['data']);
    }
    if (dataClassName == 'UpdateProductRequestDto') {
      return deserialize<_i33.UpdateProductRequestDto>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i34.Greeting>(data['data']);
    }
    if (dataClassName == 'Favorite') {
      return deserialize<_i35.Favorite>(data['data']);
    }
    if (dataClassName == 'Product') {
      return deserialize<_i36.Product>(data['data']);
    }
    if (dataClassName == 'ProductCategory') {
      return deserialize<_i37.ProductCategory>(data['data']);
    }
    if (dataClassName == 'ProductCondition') {
      return deserialize<_i38.ProductCondition>(data['data']);
    }
    if (dataClassName == 'ProductSortBy') {
      return deserialize<_i39.ProductSortBy>(data['data']);
    }
    if (dataClassName == 'ProductStatus') {
      return deserialize<_i40.ProductStatus>(data['data']);
    }
    if (dataClassName == 'TradeMethod') {
      return deserialize<_i41.TradeMethod>(data['data']);
    }
    if (dataClassName == 'CreateTransactionReviewRequestDto') {
      return deserialize<_i42.CreateTransactionReviewRequestDto>(data['data']);
    }
    if (dataClassName == 'TransactionReviewListResponseDto') {
      return deserialize<_i43.TransactionReviewListResponseDto>(data['data']);
    }
    if (dataClassName == 'TransactionReviewResponseDto') {
      return deserialize<_i44.TransactionReviewResponseDto>(data['data']);
    }
    if (dataClassName == 'ReviewType') {
      return deserialize<_i45.ReviewType>(data['data']);
    }
    if (dataClassName == 'TransactionReview') {
      return deserialize<_i46.TransactionReview>(data['data']);
    }
    if (dataClassName == 'UpdateUserProfileRequestDto') {
      return deserialize<_i47.UpdateUserProfileRequestDto>(data['data']);
    }
    if (dataClassName == 'FcmToken') {
      return deserialize<_i48.FcmToken>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i49.User>(data['data']);
    }
    if (dataClassName == 'UpdateProductStatusRequestDto') {
      return deserialize<_i50.UpdateProductStatusRequestDto>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i3.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i3.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i8.ChatMessage:
        return _i8.ChatMessage.t;
      case _i9.ChatParticipant:
        return _i9.ChatParticipant.t;
      case _i10.ChatRoom:
        return _i10.ChatRoom.t;
      case _i28.Notification:
        return _i28.Notification.t;
      case _i35.Favorite:
        return _i35.Favorite.t;
      case _i36.Product:
        return _i36.Product.t;
      case _i46.TransactionReview:
        return _i46.TransactionReview.t;
      case _i48.FcmToken:
        return _i48.FcmToken.t;
      case _i49.User:
        return _i49.User.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'gear_freak';
}
