package com.mridang.jackson.module.elastic

import com.fasterxml.jackson.databind.module.SimpleModule
import com.fasterxml.jackson.databind.{JsonMappingException, ObjectMapper}
import com.fasterxml.jackson.module.scala.DefaultScalaModule

class ElasticsearchMappingGenerator(mapper: ObjectMapper) {

  val _writer = {
    new ObjectMapper()
      .registerModule(DefaultScalaModule)
      .registerModule(new SimpleModule()
        .setSerializerModifier(new ElasticsearcSchemaBeanSerializerModifier))
  }

  def this() = this(new ObjectMapper)

  @throws[JsonMappingException]
  def generateSchema(`type`: Class[_]): Map[String, _] = {
    val visitor = new ElasticsearchSchemaFactoryWrapper(_writer.getSerializerProvider)
    _writer.acceptJsonFormatVisitor(`type`, visitor)
    _writer.convertValue(visitor.finalSchema(), classOf[Map[String, Any]])
  }

}
