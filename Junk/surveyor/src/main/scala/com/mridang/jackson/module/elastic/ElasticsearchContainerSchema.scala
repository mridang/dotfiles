package com.mridang.jackson.module.elastic

import com.fasterxml.jackson.module.jsonSchema.JsonSchema
import com.fasterxml.jackson.module.jsonSchema.types.ObjectSchema

import scala.collection.convert.DecorateAsScala

/**
 * Maps container types to Elasticsearch types. Otherwise Jackson deduces the type information
 * as [[JsonSchema]] types which will lead to wrong [[com.fasterxml.jackson.databind.annotation.JsonTypeIdResolver]]
 */
trait ElasticsearchContainerSchema
  extends ElasticsearchJsonSchemaBase
    with DecorateAsScala {
  val backing: ObjectSchema

  def getProperties: Map[String, ElasticsearchJsonSchemaBase] =
    backing.getProperties.asScala.map {
      case (k, e: ElasticsearchJsonSchemaBase) => (k, e)
      case (k, unknown) =>
        throw new IllegalArgumentException(
          s"Property $k has non-elasticsearch type ${unknown.getClass}")
    }.toMap
}
