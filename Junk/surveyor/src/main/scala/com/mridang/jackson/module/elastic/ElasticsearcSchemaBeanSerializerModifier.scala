package com.mridang.jackson.module.elastic

import com.fasterxml.jackson.databind.{BeanDescription, JsonSerializer, SerializationConfig}
import com.fasterxml.jackson.databind.ser.BeanSerializerModifier

class ElasticsearcSchemaBeanSerializerModifier extends BeanSerializerModifier {
  override def modifySerializer(
                                 config: SerializationConfig,
                                 beanDesc: BeanDescription,
                                 serializer: JsonSerializer[_]): JsonSerializer[_] = {
    if (beanDesc.getBeanClass == classOf[ElasticsearchRootSchema]) {
      new TypeOmittingSerializer(
        serializer.asInstanceOf[JsonSerializer[ElasticsearchRootSchema]])
    } else {
      serializer
    }
  }
}
