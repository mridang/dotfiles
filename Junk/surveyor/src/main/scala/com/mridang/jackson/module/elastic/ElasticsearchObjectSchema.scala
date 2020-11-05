package com.mridang.jackson.module.elastic

import com.fasterxml.jackson.annotation.JsonIgnore
import com.fasterxml.jackson.module.jsonSchema.types.ObjectSchema

import scala.annotation.meta.field

/**
 * A non-root container backed by [[ObjectSchema]] and annotated by [[ElasticsearchProperty]].
 * Used to model [[ElasticsearchProperty.Type.EMBEDDED]], [[ElasticsearchProperty.Type.NESTED]] and [[ElasticsearchProperty.Type.NESTED_OBJECT]]
 */
class ElasticsearchObjectSchema(
                                 ann: ElasticsearchProperty,
                                 @(JsonIgnore @field) override val backing: ObjectSchema)
  extends ElasticsearchAnnotatedSchema(ann)
    with ElasticsearchContainerSchema
