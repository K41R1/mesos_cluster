@REM marathon launcher script
@REM
@REM Environment:
@REM JAVA_HOME - location of a JDK home dir (optional if java on path)
@REM CFG_OPTS  - JVM options (optional)
@REM Configuration:
@REM MARATHON_config.txt found in the MARATHON_HOME.
@setlocal enabledelayedexpansion

@echo off


if "%MARATHON_HOME%"=="" (
  set "APP_HOME=%~dp0\\.."

  rem Also set the old env name for backwards compatibility
  set "MARATHON_HOME=%~dp0\\.."
) else (
  set "APP_HOME=%MARATHON_HOME%"
)

set "APP_LIB_DIR=%APP_HOME%\lib\"

rem Detect if we were double clicked, although theoretically A user could
rem manually run cmd /c
for %%x in (!cmdcmdline!) do if %%~x==/c set DOUBLECLICKED=1

rem FIRST we load the config file of extra options.
set "CFG_FILE=%APP_HOME%\MARATHON_config.txt"
set CFG_OPTS=
call :parse_config "%CFG_FILE%" CFG_OPTS

rem We use the value of the JAVACMD environment variable if defined
set _JAVACMD=%JAVACMD%

if "%_JAVACMD%"=="" (
  if not "%JAVA_HOME%"=="" (
    if exist "%JAVA_HOME%\bin\java.exe" set "_JAVACMD=%JAVA_HOME%\bin\java.exe"
  )
)

if "%_JAVACMD%"=="" set _JAVACMD=java

rem Detect if this java is ok to use.
for /F %%j in ('"%_JAVACMD%" -version  2^>^&1') do (
  if %%~j==java set JAVAINSTALLED=1
  if %%~j==openjdk set JAVAINSTALLED=1
)

rem BAT has no logical or, so we do it OLD SCHOOL! Oppan Redmond Style
set JAVAOK=true
if not defined JAVAINSTALLED set JAVAOK=false

if "%JAVAOK%"=="false" (
  echo.
  echo A Java JDK is not installed or can't be found.
  if not "%JAVA_HOME%"=="" (
    echo JAVA_HOME = "%JAVA_HOME%"
  )
  echo.
  echo Please go to
  echo   http://www.oracle.com/technetwork/java/javase/downloads/index.html
  echo and download a valid Java JDK and install before running marathon.
  echo.
  echo If you think this message is in error, please check
  echo your environment variables to see if "java.exe" and "javac.exe" are
  echo available via JAVA_HOME or PATH.
  echo.
  if defined DOUBLECLICKED pause
  exit /B 1
)


rem We use the value of the JAVA_OPTS environment variable if defined, rather than the config.
set _JAVA_OPTS=%JAVA_OPTS%
if "!_JAVA_OPTS!"=="" set _JAVA_OPTS=!CFG_OPTS!

rem We keep in _JAVA_PARAMS all -J-prefixed and -D-prefixed arguments
rem "-J" is stripped, "-D" is left as is, and everything is appended to JAVA_OPTS
set _JAVA_PARAMS=
set _APP_ARGS=

set "APP_CLASSPATH=%APP_LIB_DIR%\mesosphere.marathon.marathon-1.7.189.jar;%APP_LIB_DIR%\mesosphere.marathon.plugin-interface-1.7.189.jar;%APP_LIB_DIR%\commons-codec.commons-codec-1.9.jar;%APP_LIB_DIR%\org.eclipse.jetty.jetty-http-9.4.8.v20171121.jar;%APP_LIB_DIR%\net.logstash.logback.logstash-logback-encoder-4.9.jar;%APP_LIB_DIR%\org.apache.yetus.audience-annotations-0.5.0.jar;%APP_LIB_DIR%\org.scala-lang.scala-reflect-2.12.7.jar;%APP_LIB_DIR%\com.fasterxml.jackson.module.jackson-module-jaxb-annotations-2.9.5.jar;%APP_LIB_DIR%\org.scalamacros.resetallattrs_2.12-1.0.0.jar;%APP_LIB_DIR%\org.glassfish.jersey.core.jersey-server-2.27.jar;%APP_LIB_DIR%\io.netty.netty-3.10.5.Final.jar;%APP_LIB_DIR%\javax.xml.bind.jaxb-api-2.3.1.jar;%APP_LIB_DIR%\org.scala-lang.modules.scala-parser-combinators_2.12-1.1.0.jar;%APP_LIB_DIR%\com.fasterxml.jackson.module.jackson-module-paranamer-2.9.5.jar;%APP_LIB_DIR%\io.kamon.kamon-core_2.12-0.6.7.jar;%APP_LIB_DIR%\com.lightbend.akka.akka-stream-alpakka-s3_2.12-0.14.jar;%APP_LIB_DIR%\com.fasterxml.jackson.module.jackson-module-scala_2.12-2.9.5.jar;%APP_LIB_DIR%\com.typesafe.play.play-json_2.12-2.6.7.jar;%APP_LIB_DIR%\org.asynchttpclient.netty-codec-dns-2.0.25.jar;%APP_LIB_DIR%\org.glassfish.jersey.media.jersey-media-multipart-2.27.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-actor_2.12-2.5.14.jar;%APP_LIB_DIR%\org.asynchttpclient.netty-resolver-2.0.25.jar;%APP_LIB_DIR%\org.glassfish.hk2.hk2-api-2.5.0-b42.jar;%APP_LIB_DIR%\org.eclipse.jetty.jetty-servlet-9.4.8.v20171121.jar;%APP_LIB_DIR%\io.netty.netty-transport-4.0.43.Final.jar;%APP_LIB_DIR%\org.apache.httpcomponents.httpcore-4.4.4.jar;%APP_LIB_DIR%\javax.inject.javax.inject-1.jar;%APP_LIB_DIR%\com.getsentry.raven.raven-8.0.3.jar;%APP_LIB_DIR%\org.glassfish.jersey.containers.jersey-container-servlet-core-2.27.jar;%APP_LIB_DIR%\javax.mail.mailapi-1.4.3.jar;%APP_LIB_DIR%\com.google.guava.guava-20.0.jar;%APP_LIB_DIR%\io.kamon.kamon-scala_2.12-0.6.7.jar;%APP_LIB_DIR%\org.glassfish.jersey.media.jersey-media-jaxb-2.27.jar;%APP_LIB_DIR%\io.netty.netty-handler-4.0.43.Final.jar;%APP_LIB_DIR%\com.github.fge.json-schema-validator-2.2.6.jar;%APP_LIB_DIR%\org.apache.commons.commons-compress-1.13.jar;%APP_LIB_DIR%\org.eclipse.jetty.jetty-io-9.4.8.v20171121.jar;%APP_LIB_DIR%\com.github.fge.msg-simple-1.1.jar;%APP_LIB_DIR%\org.glassfish.jersey.core.jersey-client-2.27.jar;%APP_LIB_DIR%\net.sf.jopt-simple.jopt-simple-4.6.jar;%APP_LIB_DIR%\commons-beanutils.commons-beanutils-1.9.3.jar;%APP_LIB_DIR%\com.amazonaws.aws-java-sdk-core-1.11.243.jar;%APP_LIB_DIR%\commons-collections.commons-collections-3.2.2.jar;%APP_LIB_DIR%\org.rogach.scallop_2.12-3.1.2.jar;%APP_LIB_DIR%\org.glassfish.jersey.containers.jersey-container-servlet-2.27.jar;%APP_LIB_DIR%\com.typesafe.play.play-functional_2.12-2.6.7.jar;%APP_LIB_DIR%\com.github.fge.json-schema-core-1.2.5.jar;%APP_LIB_DIR%\org.slf4j.jul-to-slf4j-1.7.21.jar;%APP_LIB_DIR%\io.dropwizard.metrics.metrics-healthchecks-4.0.2.jar;%APP_LIB_DIR%\io.dropwizard.metrics.metrics-jvm-4.0.2.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-http_2.12-10.0.11.jar;%APP_LIB_DIR%\org.mozilla.rhino-1.7R4.jar;%APP_LIB_DIR%\io.netty.netty-buffer-4.0.43.Final.jar;%APP_LIB_DIR%\org.reactivestreams.reactive-streams-1.0.2.jar;%APP_LIB_DIR%\jline.jline-0.9.94.jar;%APP_LIB_DIR%\org.eclipse.jetty.jetty-server-9.4.8.v20171121.jar;%APP_LIB_DIR%\ch.qos.logback.logback-classic-1.2.3.jar;%APP_LIB_DIR%\org.asynchttpclient.netty-resolver-dns-2.0.25.jar;%APP_LIB_DIR%\org.scala-lang.scala-library-2.12.7.jar;%APP_LIB_DIR%\org.scala-lang.modules.scala-async_2.12-0.9.7.jar;%APP_LIB_DIR%\org.scala-lang.modules.scala-xml_2.12-1.0.6.jar;%APP_LIB_DIR%\com.fasterxml.jackson.core.jackson-core-2.9.5.jar;%APP_LIB_DIR%\io.netty.netty-common-4.0.43.Final.jar;%APP_LIB_DIR%\com.typesafe.config-1.3.3.jar;%APP_LIB_DIR%\org.glassfish.jersey.inject.jersey-hk2-2.27.jar;%APP_LIB_DIR%\com.fasterxml.jackson.datatype.jackson-datatype-jdk8-2.8.9.jar;%APP_LIB_DIR%\org.scala-lang.modules.scala-java8-compat_2.12-0.8.0.jar;%APP_LIB_DIR%\org.apache.curator.curator-x-async-4.0.1.jar;%APP_LIB_DIR%\io.dropwizard.metrics.metrics-jetty9-4.0.2.jar;%APP_LIB_DIR%\commons-io.commons-io-2.6.jar;%APP_LIB_DIR%\junit.junit-4.12.jar;%APP_LIB_DIR%\org.eclipse.jetty.jetty-util-9.4.8.v20171121.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-parsing_2.12-10.0.11.jar;%APP_LIB_DIR%\org.glassfish.hk2.external.aopalliance-repackaged-2.5.0-b42.jar;%APP_LIB_DIR%\io.kamon.kamon-datadog_2.12-0.6.7.jar;%APP_LIB_DIR%\org.eclipse.jetty.jetty-continuation-9.4.8.v20171121.jar;%APP_LIB_DIR%\io.kamon.sigar-loader-1.6.5-rev002.jar;%APP_LIB_DIR%\org.eclipse.jetty.jetty-servlets-9.4.8.v20171121.jar;%APP_LIB_DIR%\de.heikoseeberger.akka-http-play-json_2.12-1.18.1.jar;%APP_LIB_DIR%\com.getsentry.raven.raven-logback-8.0.3.jar;%APP_LIB_DIR%\org.jvnet.mimepull.mimepull-1.9.6.jar;%APP_LIB_DIR%\com.papertrail.profiler-1.0.2.jar;%APP_LIB_DIR%\org.javassist.javassist-3.22.0-CR2.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-stream_2.12-2.5.14.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-http-xml_2.12-10.0.9.jar;%APP_LIB_DIR%\org.glassfish.jersey.core.jersey-common-2.27.jar;%APP_LIB_DIR%\org.asynchttpclient.async-http-client-netty-utils-2.0.25.jar;%APP_LIB_DIR%\mesosphere.marathon.ui-1.3.1.jar;%APP_LIB_DIR%\com.github.fge.jackson-coreutils-1.8.jar;%APP_LIB_DIR%\com.thoughtworks.paranamer.paranamer-2.8.jar;%APP_LIB_DIR%\com.fasterxml.uuid.java-uuid-generator-3.1.4.jar;%APP_LIB_DIR%\javax.activation.javax.activation-api-1.2.0.jar;%APP_LIB_DIR%\com.github.fge.uri-template-0.9.jar;%APP_LIB_DIR%\io.dropwizard.metrics.metrics-core-4.0.2.jar;%APP_LIB_DIR%\software.amazon.ion.ion-java-1.0.2.jar;%APP_LIB_DIR%\org.hamcrest.hamcrest-core-1.3.jar;%APP_LIB_DIR%\joda-time.joda-time-2.9.9.jar;%APP_LIB_DIR%\org.apache.curator.curator-recipes-4.0.1.jar;%APP_LIB_DIR%\com.fasterxml.jackson.datatype.jackson-datatype-jsr310-2.8.9.jar;%APP_LIB_DIR%\com.lightbend.akka.akka-stream-alpakka-simple-codecs_2.12-0.14.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-http-core_2.12-10.0.11.jar;%APP_LIB_DIR%\org.apache.curator.curator-framework-4.0.1.jar;%APP_LIB_DIR%\io.dropwizard.metrics.metrics-servlets-4.0.2.jar;%APP_LIB_DIR%\javax.ws.rs.javax.ws.rs-api-2.1.jar;%APP_LIB_DIR%\com.typesafe.netty.netty-reactive-streams-1.0.8.jar;%APP_LIB_DIR%\io.dropwizard.metrics.metrics-annotation-4.0.2.jar;%APP_LIB_DIR%\javax.validation.validation-api-1.1.0.Final.jar;%APP_LIB_DIR%\org.apache.zookeeper.zookeeper-3.4.11.jar;%APP_LIB_DIR%\com.github.fge.btf-1.2.jar;%APP_LIB_DIR%\org.eclipse.jetty.jetty-security-9.4.8.v20171121.jar;%APP_LIB_DIR%\org.javabits.jgrapht.jgrapht-core-0.9.3.jar;%APP_LIB_DIR%\io.kamon.kamon-statsd_2.12-0.6.7.jar;%APP_LIB_DIR%\com.fasterxml.jackson.jaxrs.jackson-jaxrs-base-2.9.5.jar;%APP_LIB_DIR%\com.wix.accord-api_2.12-0.7.1.jar;%APP_LIB_DIR%\org.slf4j.slf4j-api-1.7.25.jar;%APP_LIB_DIR%\com.fasterxml.jackson.dataformat.jackson-dataformat-cbor-2.6.7.jar;%APP_LIB_DIR%\com.typesafe.scala-logging.scala-logging_2.12-3.7.2.jar;%APP_LIB_DIR%\org.typelevel.macro-compat_2.12-1.1.1.jar;%APP_LIB_DIR%\mesosphere.marathon.api-console-3.0.8-accept.jar;%APP_LIB_DIR%\org.glassfish.hk2.hk2-locator-2.5.0-b42.jar;%APP_LIB_DIR%\aopalliance.aopalliance-1.0.jar;%APP_LIB_DIR%\com.fasterxml.jackson.core.jackson-databind-2.9.5.jar;%APP_LIB_DIR%\ch.qos.logback.logback-core-1.2.3.jar;%APP_LIB_DIR%\com.wix.accord-core_2.12-0.7.1.jar;%APP_LIB_DIR%\io.kamon.kamon-system-metrics_2.12-0.6.7.jar;%APP_LIB_DIR%\org.glassfish.hk2.external.javax.inject-2.5.0-b42.jar;%APP_LIB_DIR%\io.dropwizard.metrics.metrics-jersey2-4.0.2.jar;%APP_LIB_DIR%\org.apache.curator.curator-client-4.0.1.jar;%APP_LIB_DIR%\org.glassfish.hk2.hk2-utils-2.5.0-b42.jar;%APP_LIB_DIR%\io.dropwizard.metrics.metrics-json-4.0.2.jar;%APP_LIB_DIR%\io.netty.netty-codec-http-4.0.43.Final.jar;%APP_LIB_DIR%\org.hdrhistogram.HdrHistogram-2.1.9.jar;%APP_LIB_DIR%\javax.annotation.javax.annotation-api-1.3.2.jar;%APP_LIB_DIR%\com.fasterxml.jackson.core.jackson-annotations-2.9.5.jar;%APP_LIB_DIR%\com.github.vladimir-bukhtoyarov.rolling-metrics-2.0.4.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-slf4j_2.12-2.5.14.jar;%APP_LIB_DIR%\com.google.protobuf.protobuf-java-3.5.0.jar;%APP_LIB_DIR%\javax.activation.activation-1.1.jar;%APP_LIB_DIR%\io.kamon.kamon-jmx_2.12-0.6.7.jar;%APP_LIB_DIR%\org.glassfish.hk2.osgi-resource-locator-1.0.1.jar;%APP_LIB_DIR%\org.asynchttpclient.async-http-client-2.0.25.jar;%APP_LIB_DIR%\io.netty.netty-codec-4.0.43.Final.jar;%APP_LIB_DIR%\com.google.code.findbugs.jsr305-3.0.0.jar;%APP_LIB_DIR%\com.fasterxml.jackson.jaxrs.jackson-jaxrs-json-provider-2.9.5.jar;%APP_LIB_DIR%\com.typesafe.akka.akka-protobuf_2.12-2.5.14.jar;%APP_LIB_DIR%\com.typesafe.ssl-config-core_2.12-0.2.3.jar;%APP_LIB_DIR%\com.googlecode.libphonenumber.libphonenumber-6.2.jar;%APP_LIB_DIR%\org.apache.httpcomponents.httpclient-4.5.2.jar;%APP_LIB_DIR%\org.apache.mesos.mesos-1.7.1-rc1.jar;%APP_LIB_DIR%\javax.servlet.javax.servlet-api-3.1.0.jar;%APP_LIB_DIR%\com.google.inject.guice-4.1.0.jar"
set "APP_MAIN_CLASS=mesosphere.marathon.Main"
set "SCRIPT_CONF_FILE=%APP_HOME%\conf\application.ini"

rem if configuration files exist, prepend their contents to the script arguments so it can be processed by this runner
call :parse_config "%SCRIPT_CONF_FILE%" SCRIPT_CONF_ARGS

call :process_args %SCRIPT_CONF_ARGS% %%*

set _JAVA_OPTS=!_JAVA_OPTS! !_JAVA_PARAMS!

if defined CUSTOM_MAIN_CLASS (
    set MAIN_CLASS=!CUSTOM_MAIN_CLASS!
) else (
    set MAIN_CLASS=!APP_MAIN_CLASS!
)

rem Call the application and pass all arguments unchanged.
"%_JAVACMD%" !_JAVA_OPTS! !MARATHON_OPTS! -cp "%APP_CLASSPATH%" %MAIN_CLASS% !_APP_ARGS!

@endlocal

exit /B %ERRORLEVEL%


rem Loads a configuration file full of default command line options for this script.
rem First argument is the path to the config file.
rem Second argument is the name of the environment variable to write to.
:parse_config
  set _PARSE_FILE=%~1
  set _PARSE_OUT=
  if exist "%_PARSE_FILE%" (
    FOR /F "tokens=* eol=# usebackq delims=" %%i IN ("%_PARSE_FILE%") DO (
      set _PARSE_OUT=!_PARSE_OUT! %%i
    )
  )
  set %2=!_PARSE_OUT!
exit /B 0


:add_java
  set _JAVA_PARAMS=!_JAVA_PARAMS! %*
exit /B 0


:add_app
  set _APP_ARGS=!_APP_ARGS! %*
exit /B 0


rem Processes incoming arguments and places them in appropriate global variables
:process_args
  :param_loop
  call set _PARAM1=%%1
  set "_TEST_PARAM=%~1"

  if ["!_PARAM1!"]==[""] goto param_afterloop


  rem ignore arguments that do not start with '-'
  if "%_TEST_PARAM:~0,1%"=="-" goto param_java_check
  set _APP_ARGS=!_APP_ARGS! !_PARAM1!
  shift
  goto param_loop

  :param_java_check
  if "!_TEST_PARAM:~0,2!"=="-J" (
    rem strip -J prefix
    set _JAVA_PARAMS=!_JAVA_PARAMS! !_TEST_PARAM:~2!
    shift
    goto param_loop
  )

  if "!_TEST_PARAM:~0,2!"=="-D" (
    rem test if this was double-quoted property "-Dprop=42"
    for /F "delims== tokens=1,*" %%G in ("!_TEST_PARAM!") DO (
      if not ["%%H"] == [""] (
        set _JAVA_PARAMS=!_JAVA_PARAMS! !_PARAM1!
      ) else if [%2] neq [] (
        rem it was a normal property: -Dprop=42 or -Drop="42"
        call set _PARAM1=%%1=%%2
        set _JAVA_PARAMS=!_JAVA_PARAMS! !_PARAM1!
        shift
      )
    )
  ) else (
    if "!_TEST_PARAM!"=="-main" (
      call set CUSTOM_MAIN_CLASS=%%2
      shift
    ) else (
      set _APP_ARGS=!_APP_ARGS! !_PARAM1!
    )
  )
  shift
  goto param_loop
  :param_afterloop

exit /B 0
