@echo off
set DIRNAME=%~dp0
if "%JAVA_HOME%"=="" (
  set JAVA_EXE=java.exe
) else (
  set JAVA_EXE=%JAVA_HOME%\bin\java.exe
)
"%JAVA_EXE%" -Dorg.gradle.appname=gradlew -jar "%DIRNAME%gradle\wrapper\gradle-wrapper.jar" %*
