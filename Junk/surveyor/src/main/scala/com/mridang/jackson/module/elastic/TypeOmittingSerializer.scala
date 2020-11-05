package com.mridang.jackson.module.elastic

import com.fasterxml.jackson.core.JsonGenerator
import com.fasterxml.jackson.databind.{JsonSerializer, SerializerProvider}
import com.fasterxml.jackson.databind.jsontype.TypeSerializer

/**
 * As of Jackson 2.9, we can't or we don't have to use [[com.fasterxml.jackson.databind.annotation.JsonTypeIdResolver]] / [[com.fasterxml.jackson.module.jsonSchema.JsonSchemaIdResolver]]
 * hack to overwrite the type property. Instead, omit type info completely by wiring serializeWithType to non-typed implementation
 * and simply add type as a regular property.
 */
class TypeOmittingSerializer(backing: JsonSerializer[ElasticsearchRootSchema])
  extends JsonSerializer[ElasticsearchRootSchema] {
  override def serialize(value: ElasticsearchRootSchema,
                         gen: JsonGenerator,
                         serializers: SerializerProvider): Unit =
    backing.serialize(value, gen, serializers)

  override def serializeWithType(value: ElasticsearchRootSchema,
                                 gen: JsonGenerator,
                                 serializers: SerializerProvider,
                                 typeSer: TypeSerializer): Unit = {
    backing.serialize(value, gen, serializers)
  }
}
