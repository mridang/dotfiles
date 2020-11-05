package simple.scala.gradle.project

import java.util

import com.fasterxml.jackson.annotation.JsonProperty
import com.mridang.jackson.module.elastic.{ElasticsearchMappingGenerator, ElasticsearchMappings, ElasticsearchProperty}
import org.junit.runner.RunWith
import org.scalatest.FunSuite
import org.scalatest.junit.JUnitRunner

@RunWith(classOf[JUnitRunner])
class MainSuite extends FunSuite {

  test("true is always true") {
    assert(true)
  }

  test("that beans are serialized properly") {
    val generator = new ElasticsearchMappingGenerator
    val jsonSchema = generator.generateSchema(classOf[SimpleBean])

    println(jsonSchema)
    assert(jsonSchema != null)
  }


  class SimpleBean extends ElasticsearchMappings {
    @ElasticsearchProperty(name = "foo",
      `type` = ElasticsearchProperty.Type.KEYWORD,
      index = false)
    def getName: Option[String] = Some("some")
  }

  class wdf extends ElasticsearchMappings {

    private var property1: Int = 0
    private var property2: String = null
    private var property3: Array[String] = null
    private var property4: util.Collection[Float] = null

    @JsonProperty(required = true)
    private var property5: String = null

    def getProperty1: Int = property1

    def setProperty1(property1: Int): Unit = {
      this.property1 = property1
    }

    def getProperty2: String = property2

    def setProperty2(property2: String): Unit = {
      this.property2 = property2
    }

    def getProperty3: Array[String] = property3

    def setProperty3(property3: Array[String]): Unit = {
      this.property3 = property3
    }

    def getProperty4: util.Collection[Float] = property4

    def setProperty4(property4: util.Collection[Float]): Unit = {
      this.property4 = property4
    }

    def getProperty5: String = property5

    def setProperty5(property5: String): Unit = {
      this.property5 = property5
    }
  }
}
