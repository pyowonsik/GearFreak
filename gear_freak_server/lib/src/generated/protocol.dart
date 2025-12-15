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
import 'feature/chat/model/dto/join_chat_room_response.dto.dart' as _i4;
import 'common/s3/model/dto/generate_presigned_upload_url_request.dto.dart'
    as _i5;
import 'common/s3/model/dto/generate_presigned_upload_url_response.dto.dart'
    as _i6;
import 'feature/chat/model/chat_message.dart' as _i7;
import 'feature/chat/model/chat_participant.dart' as _i8;
import 'feature/chat/model/chat_room.dart' as _i9;
import 'feature/chat/model/dto/chat_message_response.dto.dart' as _i10;
import 'feature/chat/model/dto/chat_participant_info.dto.dart' as _i11;
import 'feature/chat/model/dto/create_chat_room_request.dto.dart' as _i12;
import 'feature/chat/model/dto/create_chat_room_response.dto.dart' as _i13;
import 'feature/chat/model/dto/get_chat_messages_request.dto.dart' as _i14;
import 'feature/chat/model/dto/join_chat_room_request.dto.dart' as _i15;
import 'common/model/pagination_dto.dart' as _i16;
import 'feature/chat/model/dto/leave_chat_room_request.dto.dart' as _i17;
import 'feature/chat/model/dto/leave_chat_room_response.dto.dart' as _i18;
import 'feature/chat/model/dto/paginated_chat_messages_response.dto.dart'
    as _i19;
import 'feature/chat/model/dto/paginated_chat_rooms_response.dto.dart' as _i20;
import 'feature/chat/model/dto/send_message_request.dto.dart' as _i21;
import 'feature/chat/model/enum/chat_room_type.dart' as _i22;
import 'feature/chat/model/enum/message_type.dart' as _i23;
import 'feature/product/model/dto/create_product_request.dto.dart' as _i24;
import 'feature/product/model/dto/paginated_products_response.dto.dart' as _i25;
import 'greeting.dart' as _i26;
import 'feature/product/model/dto/update_product_request.dto.dart' as _i27;
import 'feature/product/model/dto/update_product_status_request.dto.dart'
    as _i28;
import 'feature/product/model/favorite.dart' as _i29;
import 'feature/product/model/product.dart' as _i30;
import 'feature/product/model/product_category.dart' as _i31;
import 'feature/product/model/product_condition.dart' as _i32;
import 'feature/product/model/product_sort_by.dart' as _i33;
import 'feature/product/model/product_status.dart' as _i34;
import 'feature/product/model/trade_method.dart' as _i35;
import 'feature/user/model/dto/update_user_profile_request.dto.dart' as _i36;
import 'feature/user/model/user.dart' as _i37;
import 'feature/product/model/dto/product_stats.dto.dart' as _i38;
import 'package:gear_freak_server/src/generated/feature/chat/model/chat_room.dart'
    as _i39;
import 'package:gear_freak_server/src/generated/feature/chat/model/dto/chat_participant_info.dto.dart'
    as _i40;
export 'common/model/pagination_dto.dart';
export 'common/s3/model/dto/generate_presigned_upload_url_request.dto.dart';
export 'common/s3/model/dto/generate_presigned_upload_url_response.dto.dart';
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
export 'feature/chat/model/enum/chat_room_type.dart';
export 'feature/chat/model/enum/message_type.dart';
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
export 'feature/user/model/dto/update_user_profile_request.dto.dart';
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
    if (t == _i4.JoinChatRoomResponseDto) {
      return _i4.JoinChatRoomResponseDto.fromJson(data) as T;
    }
    if (t == _i5.GeneratePresignedUploadUrlRequestDto) {
      return _i5.GeneratePresignedUploadUrlRequestDto.fromJson(data) as T;
    }
    if (t == _i6.GeneratePresignedUploadUrlResponseDto) {
      return _i6.GeneratePresignedUploadUrlResponseDto.fromJson(data) as T;
    }
    if (t == _i7.ChatMessage) {
      return _i7.ChatMessage.fromJson(data) as T;
    }
    if (t == _i8.ChatParticipant) {
      return _i8.ChatParticipant.fromJson(data) as T;
    }
    if (t == _i9.ChatRoom) {
      return _i9.ChatRoom.fromJson(data) as T;
    }
    if (t == _i10.ChatMessageResponseDto) {
      return _i10.ChatMessageResponseDto.fromJson(data) as T;
    }
    if (t == _i11.ChatParticipantInfoDto) {
      return _i11.ChatParticipantInfoDto.fromJson(data) as T;
    }
    if (t == _i12.CreateChatRoomRequestDto) {
      return _i12.CreateChatRoomRequestDto.fromJson(data) as T;
    }
    if (t == _i13.CreateChatRoomResponseDto) {
      return _i13.CreateChatRoomResponseDto.fromJson(data) as T;
    }
    if (t == _i14.GetChatMessagesRequestDto) {
      return _i14.GetChatMessagesRequestDto.fromJson(data) as T;
    }
    if (t == _i15.JoinChatRoomRequestDto) {
      return _i15.JoinChatRoomRequestDto.fromJson(data) as T;
    }
    if (t == _i16.PaginationDto) {
      return _i16.PaginationDto.fromJson(data) as T;
    }
    if (t == _i17.LeaveChatRoomRequestDto) {
      return _i17.LeaveChatRoomRequestDto.fromJson(data) as T;
    }
    if (t == _i18.LeaveChatRoomResponseDto) {
      return _i18.LeaveChatRoomResponseDto.fromJson(data) as T;
    }
    if (t == _i19.PaginatedChatMessagesResponseDto) {
      return _i19.PaginatedChatMessagesResponseDto.fromJson(data) as T;
    }
    if (t == _i20.PaginatedChatRoomsResponseDto) {
      return _i20.PaginatedChatRoomsResponseDto.fromJson(data) as T;
    }
    if (t == _i21.SendMessageRequestDto) {
      return _i21.SendMessageRequestDto.fromJson(data) as T;
    }
    if (t == _i22.ChatRoomType) {
      return _i22.ChatRoomType.fromJson(data) as T;
    }
    if (t == _i23.MessageType) {
      return _i23.MessageType.fromJson(data) as T;
    }
    if (t == _i24.CreateProductRequestDto) {
      return _i24.CreateProductRequestDto.fromJson(data) as T;
    }
    if (t == _i25.PaginatedProductsResponseDto) {
      return _i25.PaginatedProductsResponseDto.fromJson(data) as T;
    }
    if (t == _i26.Greeting) {
      return _i26.Greeting.fromJson(data) as T;
    }
    if (t == _i27.UpdateProductRequestDto) {
      return _i27.UpdateProductRequestDto.fromJson(data) as T;
    }
    if (t == _i28.UpdateProductStatusRequestDto) {
      return _i28.UpdateProductStatusRequestDto.fromJson(data) as T;
    }
    if (t == _i29.Favorite) {
      return _i29.Favorite.fromJson(data) as T;
    }
    if (t == _i30.Product) {
      return _i30.Product.fromJson(data) as T;
    }
    if (t == _i31.ProductCategory) {
      return _i31.ProductCategory.fromJson(data) as T;
    }
    if (t == _i32.ProductCondition) {
      return _i32.ProductCondition.fromJson(data) as T;
    }
    if (t == _i33.ProductSortBy) {
      return _i33.ProductSortBy.fromJson(data) as T;
    }
    if (t == _i34.ProductStatus) {
      return _i34.ProductStatus.fromJson(data) as T;
    }
    if (t == _i35.TradeMethod) {
      return _i35.TradeMethod.fromJson(data) as T;
    }
    if (t == _i36.UpdateUserProfileRequestDto) {
      return _i36.UpdateUserProfileRequestDto.fromJson(data) as T;
    }
    if (t == _i37.User) {
      return _i37.User.fromJson(data) as T;
    }
    if (t == _i38.ProductStatsDto) {
      return _i38.ProductStatsDto.fromJson(data) as T;
    }
    if (t == _i1.getType<_i4.JoinChatRoomResponseDto?>()) {
      return (data != null ? _i4.JoinChatRoomResponseDto.fromJson(data) : null)
          as T;
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
    if (t == _i1.getType<_i7.ChatMessage?>()) {
      return (data != null ? _i7.ChatMessage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.ChatParticipant?>()) {
      return (data != null ? _i8.ChatParticipant.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.ChatRoom?>()) {
      return (data != null ? _i9.ChatRoom.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.ChatMessageResponseDto?>()) {
      return (data != null ? _i10.ChatMessageResponseDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i11.ChatParticipantInfoDto?>()) {
      return (data != null ? _i11.ChatParticipantInfoDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i12.CreateChatRoomRequestDto?>()) {
      return (data != null
          ? _i12.CreateChatRoomRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i13.CreateChatRoomResponseDto?>()) {
      return (data != null
          ? _i13.CreateChatRoomResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i14.GetChatMessagesRequestDto?>()) {
      return (data != null
          ? _i14.GetChatMessagesRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i15.JoinChatRoomRequestDto?>()) {
      return (data != null ? _i15.JoinChatRoomRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i16.PaginationDto?>()) {
      return (data != null ? _i16.PaginationDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.LeaveChatRoomRequestDto?>()) {
      return (data != null ? _i17.LeaveChatRoomRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i18.LeaveChatRoomResponseDto?>()) {
      return (data != null
          ? _i18.LeaveChatRoomResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i19.PaginatedChatMessagesResponseDto?>()) {
      return (data != null
          ? _i19.PaginatedChatMessagesResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i20.PaginatedChatRoomsResponseDto?>()) {
      return (data != null
          ? _i20.PaginatedChatRoomsResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i21.SendMessageRequestDto?>()) {
      return (data != null ? _i21.SendMessageRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i22.ChatRoomType?>()) {
      return (data != null ? _i22.ChatRoomType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.MessageType?>()) {
      return (data != null ? _i23.MessageType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.CreateProductRequestDto?>()) {
      return (data != null ? _i24.CreateProductRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i25.PaginatedProductsResponseDto?>()) {
      return (data != null
          ? _i25.PaginatedProductsResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i26.Greeting?>()) {
      return (data != null ? _i26.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.UpdateProductRequestDto?>()) {
      return (data != null ? _i27.UpdateProductRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i28.UpdateProductStatusRequestDto?>()) {
      return (data != null
          ? _i28.UpdateProductStatusRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i29.Favorite?>()) {
      return (data != null ? _i29.Favorite.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i30.Product?>()) {
      return (data != null ? _i30.Product.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i31.ProductCategory?>()) {
      return (data != null ? _i31.ProductCategory.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i32.ProductCondition?>()) {
      return (data != null ? _i32.ProductCondition.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i33.ProductSortBy?>()) {
      return (data != null ? _i33.ProductSortBy.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i34.ProductStatus?>()) {
      return (data != null ? _i34.ProductStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i35.TradeMethod?>()) {
      return (data != null ? _i35.TradeMethod.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.UpdateUserProfileRequestDto?>()) {
      return (data != null
          ? _i36.UpdateUserProfileRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i37.User?>()) {
      return (data != null ? _i37.User.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i38.ProductStatsDto?>()) {
      return (data != null ? _i38.ProductStatsDto.fromJson(data) : null) as T;
    }
    if (t == List<_i10.ChatMessageResponseDto>) {
      return (data as List)
          .map((e) => deserialize<_i10.ChatMessageResponseDto>(e))
          .toList() as T;
    }
    if (t == List<_i9.ChatRoom>) {
      return (data as List).map((e) => deserialize<_i9.ChatRoom>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<String>(e)).toList()
          : null) as T;
    }
    if (t == List<_i30.Product>) {
      return (data as List).map((e) => deserialize<_i30.Product>(e)).toList()
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
    if (t == _i1.getType<List<_i39.ChatRoom>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<_i39.ChatRoom>(e)).toList()
          : null) as T;
    }
    if (t == List<_i40.ChatParticipantInfoDto>) {
      return (data as List)
          .map((e) => deserialize<_i40.ChatParticipantInfoDto>(e))
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
    if (data is _i4.JoinChatRoomResponseDto) {
      return 'JoinChatRoomResponseDto';
    }
    if (data is _i5.GeneratePresignedUploadUrlRequestDto) {
      return 'GeneratePresignedUploadUrlRequestDto';
    }
    if (data is _i6.GeneratePresignedUploadUrlResponseDto) {
      return 'GeneratePresignedUploadUrlResponseDto';
    }
    if (data is _i7.ChatMessage) {
      return 'ChatMessage';
    }
    if (data is _i8.ChatParticipant) {
      return 'ChatParticipant';
    }
    if (data is _i9.ChatRoom) {
      return 'ChatRoom';
    }
    if (data is _i10.ChatMessageResponseDto) {
      return 'ChatMessageResponseDto';
    }
    if (data is _i11.ChatParticipantInfoDto) {
      return 'ChatParticipantInfoDto';
    }
    if (data is _i12.CreateChatRoomRequestDto) {
      return 'CreateChatRoomRequestDto';
    }
    if (data is _i13.CreateChatRoomResponseDto) {
      return 'CreateChatRoomResponseDto';
    }
    if (data is _i14.GetChatMessagesRequestDto) {
      return 'GetChatMessagesRequestDto';
    }
    if (data is _i15.JoinChatRoomRequestDto) {
      return 'JoinChatRoomRequestDto';
    }
    if (data is _i16.PaginationDto) {
      return 'PaginationDto';
    }
    if (data is _i17.LeaveChatRoomRequestDto) {
      return 'LeaveChatRoomRequestDto';
    }
    if (data is _i18.LeaveChatRoomResponseDto) {
      return 'LeaveChatRoomResponseDto';
    }
    if (data is _i19.PaginatedChatMessagesResponseDto) {
      return 'PaginatedChatMessagesResponseDto';
    }
    if (data is _i20.PaginatedChatRoomsResponseDto) {
      return 'PaginatedChatRoomsResponseDto';
    }
    if (data is _i21.SendMessageRequestDto) {
      return 'SendMessageRequestDto';
    }
    if (data is _i22.ChatRoomType) {
      return 'ChatRoomType';
    }
    if (data is _i23.MessageType) {
      return 'MessageType';
    }
    if (data is _i24.CreateProductRequestDto) {
      return 'CreateProductRequestDto';
    }
    if (data is _i25.PaginatedProductsResponseDto) {
      return 'PaginatedProductsResponseDto';
    }
    if (data is _i26.Greeting) {
      return 'Greeting';
    }
    if (data is _i27.UpdateProductRequestDto) {
      return 'UpdateProductRequestDto';
    }
    if (data is _i28.UpdateProductStatusRequestDto) {
      return 'UpdateProductStatusRequestDto';
    }
    if (data is _i29.Favorite) {
      return 'Favorite';
    }
    if (data is _i30.Product) {
      return 'Product';
    }
    if (data is _i31.ProductCategory) {
      return 'ProductCategory';
    }
    if (data is _i32.ProductCondition) {
      return 'ProductCondition';
    }
    if (data is _i33.ProductSortBy) {
      return 'ProductSortBy';
    }
    if (data is _i34.ProductStatus) {
      return 'ProductStatus';
    }
    if (data is _i35.TradeMethod) {
      return 'TradeMethod';
    }
    if (data is _i36.UpdateUserProfileRequestDto) {
      return 'UpdateUserProfileRequestDto';
    }
    if (data is _i37.User) {
      return 'User';
    }
    if (data is _i38.ProductStatsDto) {
      return 'ProductStatsDto';
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
    if (dataClassName == 'JoinChatRoomResponseDto') {
      return deserialize<_i4.JoinChatRoomResponseDto>(data['data']);
    }
    if (dataClassName == 'GeneratePresignedUploadUrlRequestDto') {
      return deserialize<_i5.GeneratePresignedUploadUrlRequestDto>(
          data['data']);
    }
    if (dataClassName == 'GeneratePresignedUploadUrlResponseDto') {
      return deserialize<_i6.GeneratePresignedUploadUrlResponseDto>(
          data['data']);
    }
    if (dataClassName == 'ChatMessage') {
      return deserialize<_i7.ChatMessage>(data['data']);
    }
    if (dataClassName == 'ChatParticipant') {
      return deserialize<_i8.ChatParticipant>(data['data']);
    }
    if (dataClassName == 'ChatRoom') {
      return deserialize<_i9.ChatRoom>(data['data']);
    }
    if (dataClassName == 'ChatMessageResponseDto') {
      return deserialize<_i10.ChatMessageResponseDto>(data['data']);
    }
    if (dataClassName == 'ChatParticipantInfoDto') {
      return deserialize<_i11.ChatParticipantInfoDto>(data['data']);
    }
    if (dataClassName == 'CreateChatRoomRequestDto') {
      return deserialize<_i12.CreateChatRoomRequestDto>(data['data']);
    }
    if (dataClassName == 'CreateChatRoomResponseDto') {
      return deserialize<_i13.CreateChatRoomResponseDto>(data['data']);
    }
    if (dataClassName == 'GetChatMessagesRequestDto') {
      return deserialize<_i14.GetChatMessagesRequestDto>(data['data']);
    }
    if (dataClassName == 'JoinChatRoomRequestDto') {
      return deserialize<_i15.JoinChatRoomRequestDto>(data['data']);
    }
    if (dataClassName == 'PaginationDto') {
      return deserialize<_i16.PaginationDto>(data['data']);
    }
    if (dataClassName == 'LeaveChatRoomRequestDto') {
      return deserialize<_i17.LeaveChatRoomRequestDto>(data['data']);
    }
    if (dataClassName == 'LeaveChatRoomResponseDto') {
      return deserialize<_i18.LeaveChatRoomResponseDto>(data['data']);
    }
    if (dataClassName == 'PaginatedChatMessagesResponseDto') {
      return deserialize<_i19.PaginatedChatMessagesResponseDto>(data['data']);
    }
    if (dataClassName == 'PaginatedChatRoomsResponseDto') {
      return deserialize<_i20.PaginatedChatRoomsResponseDto>(data['data']);
    }
    if (dataClassName == 'SendMessageRequestDto') {
      return deserialize<_i21.SendMessageRequestDto>(data['data']);
    }
    if (dataClassName == 'ChatRoomType') {
      return deserialize<_i22.ChatRoomType>(data['data']);
    }
    if (dataClassName == 'MessageType') {
      return deserialize<_i23.MessageType>(data['data']);
    }
    if (dataClassName == 'CreateProductRequestDto') {
      return deserialize<_i24.CreateProductRequestDto>(data['data']);
    }
    if (dataClassName == 'PaginatedProductsResponseDto') {
      return deserialize<_i25.PaginatedProductsResponseDto>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i26.Greeting>(data['data']);
    }
    if (dataClassName == 'UpdateProductRequestDto') {
      return deserialize<_i27.UpdateProductRequestDto>(data['data']);
    }
    if (dataClassName == 'UpdateProductStatusRequestDto') {
      return deserialize<_i28.UpdateProductStatusRequestDto>(data['data']);
    }
    if (dataClassName == 'Favorite') {
      return deserialize<_i29.Favorite>(data['data']);
    }
    if (dataClassName == 'Product') {
      return deserialize<_i30.Product>(data['data']);
    }
    if (dataClassName == 'ProductCategory') {
      return deserialize<_i31.ProductCategory>(data['data']);
    }
    if (dataClassName == 'ProductCondition') {
      return deserialize<_i32.ProductCondition>(data['data']);
    }
    if (dataClassName == 'ProductSortBy') {
      return deserialize<_i33.ProductSortBy>(data['data']);
    }
    if (dataClassName == 'ProductStatus') {
      return deserialize<_i34.ProductStatus>(data['data']);
    }
    if (dataClassName == 'TradeMethod') {
      return deserialize<_i35.TradeMethod>(data['data']);
    }
    if (dataClassName == 'UpdateUserProfileRequestDto') {
      return deserialize<_i36.UpdateUserProfileRequestDto>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i37.User>(data['data']);
    }
    if (dataClassName == 'ProductStatsDto') {
      return deserialize<_i38.ProductStatsDto>(data['data']);
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
      case _i7.ChatMessage:
        return _i7.ChatMessage.t;
      case _i8.ChatParticipant:
        return _i8.ChatParticipant.t;
      case _i9.ChatRoom:
        return _i9.ChatRoom.t;
      case _i29.Favorite:
        return _i29.Favorite.t;
      case _i30.Product:
        return _i30.Product.t;
      case _i37.User:
        return _i37.User.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'gear_freak';
}
