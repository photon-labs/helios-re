package com.photon.reverseEngg;

import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;

import com.mxgraph.swing.mxGraphComponent;
import com.mxgraph.view.mxGraph;
import com.mxgraph.view.mxStylesheet;
import com.mxgraph.layout.hierarchical.mxHierarchicalLayout;
import com.mxgraph.util.mxCellRenderer;
import com.mxgraph.util.mxCellRenderer.CanvasFactory;
import com.mxgraph.util.mxUtils;
import com.mxgraph.util.mxXmlUtils;
import com.mxgraph.util.mxDomUtils;
import com.mxgraph.util.mxRectangle;
import com.mxgraph.util.mxConstants;
import com.mxgraph.util.png.mxPngEncodeParam;
import com.mxgraph.util.png.mxPngImageEncoder;
import com.mxgraph.util.png.mxPngTextDecoder;
import com.mxgraph.model.mxGeometry;
import com.mxgraph.model.mxCell;
import com.mxgraph.io.mxCodec;
import com.mxgraph.canvas.mxSvgCanvas;
import com.mxgraph.canvas.mxICanvas;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.File;
import java.io.IOException;

import javax.swing.SwingConstants;

import java.awt.Color;
import java.awt.image.BufferedImage;

import java.net.URLEncoder;

import java.lang.NullPointerException;

import java.util.List;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Hashtable;

@SuppressWarnings({"deprecation","unchecked"})

public class Main{

	public static int count = 0;
	public static List<Map<String,String>> finalList = new ArrayList<Map<String,String>>();
	public static List<Map<String,String>> methodList = new ArrayList<Map<String,String>>();
	public static List<Map<String,String>> varList = new ArrayList<Map<String,String>>();

	static class DetailsExtractor extends ObjectiveCBaseListener{
		
		String className="null",parentName="null";
		boolean flag=false;

		@Override 
		public void enterInterface_declaration(ObjectiveCParser.Interface_declarationContext ctx){
			className = ctx.class_name().IDENTIFIER().getText();

			try{
				parentName = ctx.superclass_name().IDENTIFIER().getText();
			} catch (NullPointerException e) {
				parentName = "null";
			}

			Map<String,String> classMap = new LinkedHashMap<String,String>();
			classMap.put("name",className);
			classMap.put("parent",parentName);

			for(Map<String,String> iMap : finalList){
				if(iMap.get("name").equals(className)){
					flag=true;
					if(iMap.get("parent").equals("null")){
						iMap.put("parent",parentName);
					}
				}
			}

			if(flag==false)
				finalList.add(classMap);
			
			flag=false;

			if(!parentName.equals("null")){
				for(Map<String,String> iMap : finalList){
					if(iMap.get("name").equals(parentName))
						flag=true;
				}

				if(flag==false){
					Map<String,String> parentclassMap = new LinkedHashMap<String,String>();
					parentclassMap.put("name",parentName);
					parentclassMap.put("parent","null");

					finalList.add(parentclassMap);
				}
			}
		}

		@Override
		public void enterClass_implementation(ObjectiveCParser.Class_implementationContext ctx){
			className = ctx.class_name().IDENTIFIER().getText();
		}

		@Override
		public void enterInstance_method_declaration(ObjectiveCParser.Instance_method_declarationContext ctx){

			String methodName="null",returnType="null";

			try{
				methodName = ctx.method_declaration().method_selector().selector().IDENTIFIER().getText();
				returnType = ctx.method_declaration().method_type().type_name().specifier_qualifier_list().type_specifier(0).getText();
			} catch (NullPointerException e) {
				try{
					methodName = ctx.method_declaration().method_selector().keyword_declarator(0).selector().IDENTIFIER().getText();
					returnType = ctx.method_declaration().method_type().type_name().specifier_qualifier_list().type_specifier(0).class_name().IDENTIFIER().getText();
				} catch(NullPointerException f) { methodName = "null"; returnType=" ";}
			}

			addMethod("-",methodName,returnType);
		}

		@Override
		public void enterClass_method_declaration(ObjectiveCParser.Class_method_declarationContext ctx){

			String methodName="null",returnType="null";

			try{
				methodName = ctx.method_declaration().method_selector().selector().IDENTIFIER().getText();
				returnType = ctx.method_declaration().method_type().type_name().specifier_qualifier_list().type_specifier(0).getText();
			} catch (NullPointerException e) {
				try{
					methodName = ctx.method_declaration().method_selector().keyword_declarator(0).selector().IDENTIFIER().getText();
					returnType = ctx.method_declaration().method_type().type_name().specifier_qualifier_list().type_specifier(0).class_name().IDENTIFIER().getText();
				} catch(NullPointerException f) { methodName = "null"; }
			}

			addMethod("+",methodName,returnType);

		}

		@Override
		public void enterInstance_method_definition(ObjectiveCParser.Instance_method_definitionContext ctx){

			String methodName="null",returnType="null";

			try{
				methodName = ctx.method_definition().method_selector().selector().IDENTIFIER().getText();
				returnType = ctx.method_definition().method_type().type_name().specifier_qualifier_list().type_specifier(0).getText();
			} catch (NullPointerException e) {
				try{
					methodName = ctx.method_definition().method_selector().keyword_declarator(0).selector().IDENTIFIER().getText();
					returnType = ctx.method_definition().method_type().type_name().specifier_qualifier_list().type_specifier(0).class_name().IDENTIFIER().getText();
				} catch(NullPointerException f) { methodName = "null"; }
			}

			addMethod("-",methodName,returnType);
		}

		@Override
		public void enterClass_method_definition(ObjectiveCParser.Class_method_definitionContext ctx){

			String methodName="null",returnType="null";

			try{
				methodName = ctx.method_definition().method_selector().selector().IDENTIFIER().getText();
				returnType = ctx.method_definition().method_type().type_name().specifier_qualifier_list().type_specifier(0).getText();
			} catch (NullPointerException e) {
				try{
					methodName = ctx.method_definition().method_selector().keyword_declarator(0).selector().IDENTIFIER().getText();
					returnType = ctx.method_definition().method_type().type_name().specifier_qualifier_list().type_specifier(0).class_name().IDENTIFIER().getText();
				} catch(NullPointerException f) { methodName = "null"; }
			}

			addMethod("+",methodName,returnType);
		}

		@Override
		public void enterInstance_variable_declaration(ObjectiveCParser.Instance_variable_declarationContext ctx){
			String varName = "null", returnType = "null";

			try{
				varName = ctx.init_declarator_list(0).init_declarator(0).declarator().declarator().direct_declarator().IDENTIFIER().getText();
				try{
					returnType = ctx.specifier_qualifier_list(0).type_specifier(0).class_name().IDENTIFIER().getText() + " " + ctx.specifier_qualifier_list(0).type_specifier(1).class_name().IDENTIFIER().getText() + " * ";
				} catch(NullPointerException e){
					returnType = ctx.specifier_qualifier_list(0).type_specifier(0).class_name().IDENTIFIER().getText() + " * ";
				}
			} catch(NullPointerException e){
				try{
					varName = ctx.specifier_qualifier_list(0).type_specifier(1).class_name().IDENTIFIER().getText();
					returnType = ctx.specifier_qualifier_list(0).type_specifier(0).getText() ;
				} catch(NullPointerException f){
					varName = "null";
					returnType = "null";
				}
			}

			Map<String,String> varMap = new LinkedHashMap<String,String>();
			
			varMap.put("className",className);

			varMap.put("field",varName + " : " + returnType);
			
			if(!varList.contains(varMap))
				varList.add(varMap);
		}

		public void addMethod(String methodType, String methodName, String returnType){
			Map<String,String> methodMap = new LinkedHashMap<String,String>();
			
			methodMap.put("className",className);

			methodMap.put("method",methodType + " " + methodName + "( ) : " + returnType);
			
			if(!methodList.contains(methodMap))
				methodList.add(methodMap);
		}
	}

	/*protected void exportImage(String filename, mxGraph graph, mxGraphComponent graphComponent) throws IOException{

		BufferedImage image = mxCellRenderer.createBufferedImage(graph,	null, 1, Color.WHITE, graphComponent.isAntiAlias(), null,graphComponent.getCanvas());

		// Creates the URL-encoded XML data
		mxCodec codec = new mxCodec();
		String xml = URLEncoder.encode(mxXmlUtils.getXml(codec.encode(graph.getModel())), "UTF-8");

		mxPngEncodeParam param = mxPngEncodeParam.getDefaultEncodeParam(image);
		param.setCompressedText(new String[] { "mxGraphModel", xml });

		// Saves as a PNG file
		FileOutputStream outputStream = new FileOutputStream(new File(filename));

		try
		{
			mxPngImageEncoder encoder = new mxPngImageEncoder(outputStream,param);

			if (image != null)
			{
				encoder.encode(image);
			}
			else
			{
				System.out.println("No Image");
			}
		}
		finally
		{
			outputStream.close();
		}
	}

	protected void exportHTML(String filename, mxGraph graph, mxGraphComponent graphComponent) throws IOException{
		mxUtils.writeFile(mxXmlUtils.getXml(mxCellRenderer
								.createHtmlDocument(graph, null, 1, null, null)
								.getDocumentElement()), filename);
	}*/

	protected void exportSVG(String filename, mxGraph graph, mxGraphComponent graphComponent) throws IOException{
		mxSvgCanvas canvas = (mxSvgCanvas) mxCellRenderer.drawCells(graph, null, 1, null,
								new CanvasFactory()
								{
									public mxICanvas createCanvas(int width, int height)
									{
										mxSvgCanvas canvas = new mxSvgCanvas(mxDomUtils.createSvgDocument(width, height));
										canvas.setEmbedded(true);

										return canvas;
									}
								});

		mxUtils.writeFile(mxXmlUtils.getXml(canvas.getDocument()),filename);
	}

	public Main() throws Exception{
		List<Map<String,Object>> nodeList = new ArrayList<Map<String,Object>>();

		Object source=null,dest=null;
		String label=null,curClass=null;
		boolean edgeFlag=false;

		mxGraph graph = new mxGraph();

		mxGraphComponent graphComponent = new mxGraphComponent(graph);

		Object defaultParent = graph.getDefaultParent();

		graph.getModel().beginUpdate();

		for(Map<String,String>map : finalList){
			curClass = map.get("name");
			label = curClass + "\n__________________\n\nAttributes : \n";

			for(Map<String,String>varMap : varList){
					if(varMap.get("className").equals(curClass))
						if(!varMap.get("field").contains("null :"))
						label += "\n"+varMap.get("field");
			}

			label += "\n__________________\n\nMethods : \n";

			for(Map<String,String>methodMap : methodList){
					if(methodMap.get("className").equals(curClass))
						if(!methodMap.get("method").contains("null( )"))
							label += "\n"+methodMap.get("method");
			}

			Object v = graph.insertVertex(defaultParent, null, label, 20, 20, 160, 30);

			Map<String,Object> nodeMap = new LinkedHashMap<String,Object>();
			nodeMap.put(curClass,v);
			
			if(!nodeList.contains(nodeMap))
				nodeList.add(nodeMap);				
		}

		for(Map<String,String>finalMap : finalList){
			edgeFlag = false;
			for(String key : finalMap.keySet()){
				if(!finalMap.get("parent").equals("null")){
					edgeFlag = true;
					for(Map<String,Object>nodeMap : nodeList){
						for(String nodeKey : nodeMap.keySet()){
							if(finalMap.get("name").equals(nodeKey))
								source = nodeMap.get(nodeKey);

							if(finalMap.get("parent").equals(nodeKey))
								dest = nodeMap.get(nodeKey);
						}
					}
				}
			}
			if(edgeFlag)
				graph.insertEdge(defaultParent,null,"",dest,source);
		}
		graph.getModel().endUpdate();

		graph.getModel().beginUpdate();

	    for(Map<String,Object>nodeMap : nodeList){
	    	for(String nodeKey : nodeMap.keySet()){
	    		mxCell cell = (mxCell)nodeMap.get(nodeKey);
	    		mxGeometry g = (mxGeometry) cell.getGeometry().clone();
		        mxRectangle bounds = graph.getView().getState(cell).getLabelBounds();
		        g.setHeight(bounds.getHeight() + 10);
		        g.setWidth(bounds.getWidth() + 10);
		        graph.cellsResized(new Object[] { cell }, new mxRectangle[] { g });
	    	}
	    }
		
		mxHierarchicalLayout layout = new mxHierarchicalLayout(graph);
        layout.setIntraCellSpacing(10);
		layout.setInterRankCellSpacing(300);
		layout.execute(defaultParent);
		graph.getModel().endUpdate();

    	File outputDir = new File("output");

    	if(!outputDir.exists()){
    		boolean result = outputDir.mkdir();  
    	}

		/*exportImage("output" + File.separator + "result.png",graph,graphComponent);
    	System.out.println("\nImage saved!");

		exportHTML("output" + File.separator + "result.html",graph,graphComponent);
		System.out.println("\nHTML saved!");*/

		exportSVG("output" + File.separator + "result.svg",graph,graphComponent);
		System.out.println("\nSVG saved!");		
	}

	public static void fileProcessor(File[] files) throws Exception{
    	for(File file : files) {
    		if(file.isDirectory()){
    			System.out.println("\nDirectory : "+file.getName()+"\n");
    			fileProcessor(file.listFiles());
    		}
    		else {
    			String extension = file.getName().substring(file.getName().length()-2);
    			String big_extension = file.getName().substring(file.getName().length()-3);
    			if(extension.equals(".h") || extension.equals(".m") || big_extension.equals(".mm")) {
    				System.out.println("File : " + file.getName());

    				count++;

    				InputStream is = System.in;

    				if(file!=null) is=new FileInputStream(file);

    				ANTLRInputStream input = new ANTLRInputStream(is);

    				ObjectiveCLexer lexer = new ObjectiveCLexer(input);

    				CommonTokenStream tokens = new CommonTokenStream(lexer);

    				ObjectiveCParser parser = new ObjectiveCParser(tokens);

    				ParseTree tree = parser.translation_unit();

    				DetailsExtractor extractor = new DetailsExtractor();

    				ParseTreeWalker walker = new ParseTreeWalker();
    				
    				walker.walk(extractor,tree);
    			}
    		}
    	}
    }

    public static void main(String[] args) throws Exception{

    	System.setProperty("java.util.Arrays.useLegacyMergeSort", "true");

    	String currentClass="null";

    	String dirName = null;

    	if (args.length>0) dirName = args[0];

    	File directory = new File(dirName);

    	File[] filesInDir = directory.listFiles();

    	fileProcessor(filesInDir);

    	System.out.println("\nFiles parsed : "+count);
    	
    	Main frame = new Main();
    }
}