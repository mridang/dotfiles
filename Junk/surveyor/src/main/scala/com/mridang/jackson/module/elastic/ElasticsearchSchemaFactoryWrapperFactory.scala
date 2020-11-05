package com.mridang.jackson.module.elastic

import com.fasterxml.jackson.databind.SerializerProvider
import com.fasterxml.jackson.module.jsonSchema.factories.{SchemaFactoryWrapper, VisitorContext, WrapperFactory}

/**
 * Allows overwriting expectXFormat methods by instantiating sublasses of
 * [[SchemaFactoryWrapper]] instead of the default implementations.
 */
object ElasticsearchSchemaFactoryWrapperFactory extends WrapperFactory {
  override def getWrapper(provider: SerializerProvider): SchemaFactoryWrapper = {
    new ElasticsearchSchemaFactoryWrapper(provider)
  }

  override def getWrapper(provider: SerializerProvider,
                          rvc: VisitorContext): SchemaFactoryWrapper = {
    new ElasticsearchSchemaFactoryWrapper(provider).setVisitorContext(rvc)
  }
}
