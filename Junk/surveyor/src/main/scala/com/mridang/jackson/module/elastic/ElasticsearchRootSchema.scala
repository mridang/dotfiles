package com.mridang.jackson.module.elastic

import com.fasterxml.jackson.annotation.JsonIgnore
import com.fasterxml.jackson.module.jsonSchema.types.ObjectSchema

import scala.annotation.meta.field

/**
 * A root schema that is backed by [[ObjectSchema]]. We can't use [[ElasticsearchObjectSchema]]
 * as the root is not annotated and contains no type information.
 */
class ElasticsearchRootSchema(
                               @(JsonIgnore @field) override val backing: ObjectSchema)
  extends ElasticsearchJsonSchemaBase
    with ElasticsearchContainerSchema
