Reverse Engineering
===================
-------------------

The objective is to create a tool that is capable of processing large number of Objective-C source files and which gives the overview and inheritance-dependencies of the project with the help of UML diagrams.

Installation Steps
==================

1. Install Maven.

2. Install the JGraphX JAR in the Maven Local Repository using the command : 

	mvn install:install-file -Dfile=lib\jgraphx.jar -DgroupId=com.mxgraph -DartifactId=jgraphx -Dversion=1.0 -Dpackaging=jar

3. Build the project using the command : 

	mvn clean install

4. Run the project using the command :
	
	java -cp target\objective-c-0.1-SNAPSHOT-jar-with-dependencies.jar -Xmx1024m com.photon.reverseEngg.Main input

5. The resulting image will be saved in the directory "output" as "result.svg".