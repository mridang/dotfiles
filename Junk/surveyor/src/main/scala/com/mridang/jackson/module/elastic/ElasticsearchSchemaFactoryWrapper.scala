package com.mridang.jackson.module.elastic

import com.fasterxml.jackson.databind.{BeanProperty, JavaType, SerializerProvider}
import com.fasterxml.jackson.databind.jsonFormatVisitors.{JsonFormatVisitable, JsonObjectFormatVisitor}
import com.fasterxml.jackson.module.jsonSchema.JsonSchema
import com.fasterxml.jackson.module.jsonSchema.factories.{ObjectVisitor, SchemaFactoryWrapper, VisitorContext}
import com.fasterxml.jackson.module.jsonSchema.types.ArraySchema.SingleItems
import com.fasterxml.jackson.module.jsonSchema.types.{ArraySchema, ObjectSchema}

/**
 * A customized visitor that intercepts generated [[JsonSchema]] instances
 * and uses [[ElasticsearchJsonSchemaBase]] based objects instead.
 */
class ElasticsearchSchemaFactoryWrapper(
                                         _provider: SerializerProvider /* use only as an initial value!! */ )
  extends SchemaFactoryWrapper(_provider,
    ElasticsearchSchemaFactoryWrapperFactory) {

  /**
   * Customised [[ObjectSchema]] visits:
   * - Disable reference schemas as there is no support for such things in Elasticsearch (so don't call visitorContext.addSeenSchemaUri)
   * - Put [[ElasticsearchJsonSchemaBase]] based objects to schema instead of standard [[JsonSchema]] ones.
   */
  override def expectObjectFormat(
                                   convertedType: JavaType): JsonObjectFormatVisitor = {
    val s = schemaProvider.objectSchema
    schema = new ElasticsearchRootSchema(s)

    // if we don't already have a recursive visitor context, create one
    if (visitorContext == null) visitorContext = new VisitorContext

    new ObjectVisitor(provider, s, ElasticsearchSchemaFactoryWrapperFactory) {
      setVisitorContext(visitorContext)
      override def optionalProperty(prop: BeanProperty): Unit = {
        val ann = prop.getAnnotation(classOf[ElasticsearchProperty])
        if (ann != null) {
          val ps = propertySchema(prop)

          ps match {
            case _: ElasticsearchJsonSchemaBase =>
              schema.putOptionalProperty(ann.name(), ps)
            case a: ArraySchema =>
              val inner = a.getItems match {
                case s: SingleItems =>
                  s.getSchema match {
                    case rootSchema: ElasticsearchRootSchema =>
                      new ElasticsearchObjectSchema(ann, rootSchema.backing)
                    case os: ObjectSchema =>
                      new ElasticsearchObjectSchema(ann, os)
                    case _ => new ElasticsearchAnnotatedSchema(ann)
                  }
                case null => new ElasticsearchAnnotatedSchema(ann)
              }

              schema.putOptionalProperty(ann.name(), inner)
            case os: ObjectSchema =>
              schema.putOptionalProperty(
                ann.name(),
                new ElasticsearchObjectSchema(ann, os))
            case _ =>
              schema.putOptionalProperty(ann.name(),
                new ElasticsearchAnnotatedSchema(ann))
          }
        }
      }

      /**
       * Not implemented as there has not been a use-case.
       * Throws to avoid accidental use of the default implementation.
       */
      //noinspection NotImplementedCode
      override def optionalProperty(name: String,
                                    handler: JsonFormatVisitable,
                                    propertyTypeHint: JavaType): Unit = ???

      /**
       * Not implemented as there has not been a use-case.
       * Throws to avoid accidental use of the default implementation.
       */
      //noinspection NotImplementedCode
      override def property(prop: BeanProperty): Unit = ???

      /**
       * Not implemented as there has not been a use-case.
       * Throws to avoid accidental use of the default implementation.
       */
      //noinspection NotImplementedCode
      override def property(name: String,
                            handler: JsonFormatVisitable,
                            propertyTypeHint: JavaType): Unit = ???
    }
  }
}
