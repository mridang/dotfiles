package com.mridang.jackson.module.elastic

import com.fasterxml.jackson.databind.jsonFormatVisitors.JsonFormatTypes
import com.fasterxml.jackson.module.jsonSchema.JsonSchema

abstract class ElasticsearchJsonSchemaBase extends JsonSchema {

  override def getType: JsonFormatTypes =
    JsonFormatTypes.ANY // the value is irrelevant
}
