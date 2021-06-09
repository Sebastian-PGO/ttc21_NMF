package ttc2021

import java.io.File
import java.io.IOException
import java.util.HashMap

import java.nio.file.Files
import java.nio.file.Paths

import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.XMLResource
import org.eclipse.emf.ecore.xmi.impl.EcoreResourceFactoryImpl
import org.eclipse.emf.ecore.xmi.impl.XMIResourceImpl

import jobCollection.JobCollectionPackage
import laboratoryAutomation.LaboratoryAutomationPackage
import laboratoryAutomation.JobRequest

class LiveContestDriver {

	def static void main(String[] args) {
		try {
	        initialize
	        load
	        initial
            for (i : 1 .. Sequences) {
	            update(i)
	        }	
		} catch(Exception e) {
			e.printStackTrace
		}
	}
	

    static var ResourceSet repository

    static var String RunIndex
    static var String Tool
    static var String Scenario
    static var int Sequences
    static var String Model
    static var String ModelPath

    static var long stopwatch

    static var Solution solution

    def private static EObject loadFile(String path) {
		try {
			return repository.getResource(URI.createFileURI(new File('''«ModelPath»/«path»''').getCanonicalPath()), true).contents.get(0)
		} catch (IOException e) {
			throw new RuntimeException(e)
		}
    }

    def static void load()
    {
    	stopwatch = System.nanoTime
        solution.load(loadFile("initial.xmi") as JobRequest)
        stopwatch = System.nanoTime - stopwatch
        report(BenchmarkPhase.Load, -1, null)
    }

    def static void initialize() throws Exception
    {
    	stopwatch = System.nanoTime

    	repository = new ResourceSetImpl
		repository.resourceFactoryRegistry.extensionToFactoryMap.put("xmi", new Resource.Factory() {
			override Resource createResource(URI uri) {
				val XMIResourceImpl ret = new XMIResourceImpl(uri)
				ret.setIntrinsicIDToEObjectMap(new HashMap)
				ret.getDefaultLoadOptions().put(XMLResource.OPTION_DEFER_IDREF_RESOLUTION, true)
				return ret
			}
		});
		repository.resourceFactoryRegistry.extensionToFactoryMap.put("ecore", new EcoreResourceFactoryImpl());
		repository.packageRegistry.put(JobCollectionPackage.eINSTANCE.getNsURI(), JobCollectionPackage.eINSTANCE);
		repository.packageRegistry.put(LaboratoryAutomationPackage.eINSTANCE.getNsURI(), LaboratoryAutomationPackage.eINSTANCE);

        RunIndex = System.getenv("RunIndex")
        Tool = System.getenv("Tool")
        Scenario = System.getenv("Scenario")
        Sequences = Integer.parseInt(System.getenv("Sequences"))
        Model = System.getenv("Model")
        ModelPath = System.getenv("ModelPath")

        solution = new ATOLSolution

        stopwatch = System.nanoTime - stopwatch
        report(BenchmarkPhase.Initialization, -1, null)
    }

    def static void initial()
    {
        stopwatch = System.nanoTime
        val result = solution.initial
        stopwatch = System.nanoTime - stopwatch
        report(BenchmarkPhase.Initial, -1, null)

        saveModel(result, '''«ModelPath»/results/initialResult-«Tool».xmi''')
    }

    def static void update(int iteration)
    {
        val iterationStr = String.format('%02d', iteration)
        val changes = Files.lines(Paths.get('''«ModelPath»/change«iterationStr».txt'''))
        solution.computeChanges(changes)
        stopwatch = System.nanoTime
        val result = solution.applyChanges
        stopwatch = System.nanoTime - stopwatch;
        report(BenchmarkPhase.Update, iteration, null)

        saveModel(result, '''«ModelPath»/results/change«iterationStr»Result-«Tool».xmi''')
    }

    def static void report(BenchmarkPhase phase, int iteration, String result)
    {
        var String iterationStr
        if (iteration == -1) {
            iterationStr = "0";
        } else {
            iterationStr = Integer.toString(iteration)
        }
        println('''«Tool»;«Scenario»;«Model»;«RunIndex»;«iterationStr»;«phase»;Time;«Long.toString(stopwatch)»''')
        if("true".equals(System.getenv("NoGC"))) {
            // nothing to do
        }
        else {
            Runtime.getRuntime().gc
            Runtime.getRuntime().gc
            Runtime.getRuntime().gc
            Runtime.getRuntime().gc
            Runtime.getRuntime().gc
        }
        val memoryUsed = Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory();
        println('''«Tool»;«Scenario»;«Model»;«RunIndex»;«iterationStr»;«phase»;Memory;«Long.toString(memoryUsed)»''')
    }

    enum BenchmarkPhase {
        Initialization,
        Load,
        Initial,
        Update
    }

    def static void saveModel(EObject model, String path) {
        val res = repository.createResource(URI.createFileURI(path))
        res.contents.add(model)
        res.save(#{XMLResource.OPTION_ENCODING -> "utf-8"})
    }
}
