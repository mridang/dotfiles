package com.mridang.jackson.module.elastic

import com.fasterxml.jackson.annotation.JsonProperty

/**
 * A subset of Elasticsearch mapping parameters, see
 * [[https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-params.html]]
 * Only params needed so far have been implemented.
 */
class ElasticsearchAnnotatedSchema(ann: ElasticsearchProperty)
  extends ElasticsearchJsonSchemaBase {

  @JsonProperty("type")
  def getElasticsearchType: String = ann.`type`().toString

  def getAnalyzer: String = ann.analyzer()

  def getNormalizer: String = ann.normalizer()

  def getIndex: Option[Boolean] =
    onlyIfDifferent(_.index, ElasticsearchProperty.DEFAULT_INDEX)

  def getStore: Option[Boolean] =
    onlyIfDifferent(_.store, ElasticsearchProperty.DEFAULT_STORE)

  // Note: jackson does not recognize isEnabled: Option[Boolean] as a bean
  def getEnabled: Option[Boolean] =
    onlyIfDifferent(_.enabled, ElasticsearchProperty.DEFAULT_ENABLED)

  def getNorms: Option[Boolean] =
    onlyIfDifferent(_.norms, ElasticsearchProperty.DEFAULT_NORMS)

  @JsonProperty("index_options")
  def getIndexOptions: String = ann.index_options()

  def getSimilarity: String = ann.similarity()

  def getFormat: String = ann.format()

  /**
   * Improves human-readability by omitting parameters with default values.
   */
  private def onlyIfDifferent[T](f: ElasticsearchProperty => T,
                                 default: T): Option[T] =
    Some(f(ann)).filter(_ != default)

}
