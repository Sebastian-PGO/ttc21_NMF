package ttc2021

import java.util.HashMap

import fr.eseo.atol.gen.AbstractRule

import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.papyrus.aof.core.IBox
import fr.eseo.aof.xtend.utils.AOFAccessors
import laboratoryAutomation.LaboratoryAutomationPackage
import laboratoryAutomation.Sample
import laboratoryAutomation.SampleState
import laboratoryAutomation.JobRequest
import org.eclipse.papyrus.aof.core.AOFFactory
import fr.eseo.atol.gen.Metaclass

import static fr.eseo.atol.gen.MetamodelUtils.*

@AOFAccessors(LaboratoryAutomationPackage)
class LaboratoryAutomation {
    public static val Metaclass<Tubes> Tubes = [new Tubes]
    public static val Metaclass<ProcessWell> ProcessWell = [new ProcessWell]
    public static val Metaclass<ProcessColumn> ProcessColumn = [new ProcessColumn]
    public static val Metaclass<ProcessPlate> ProcessPlate = [new ProcessPlate]

    public var tubesCache = new HashMap<JobRequest, IBox<Tubes>>
    def _tubes(JobRequest it) {
        tubesCache.computeIfAbsent(it)[AOFFactory.INSTANCE.createSequence]
    }

    public var processPlatesCache = new HashMap<JobRequest, IBox<ProcessPlate>>
    def _processPlates(JobRequest it) {
        processPlatesCache.computeIfAbsent(it)[AOFFactory.INSTANCE.createSequence]
    }

    @Data
    static class ProcessWell {
        val IBox<Integer> well = AOFFactory.INSTANCE.createOption
        val IBox<Sample> sample = AOFFactory.INSTANCE.createOption
    }
    def _well(ProcessWell it) {
        well
    }
    def well(IBox<ProcessWell> it) {
        collectMutable[it?._well ?: AbstractRule.emptyOption]
    }
    def _sample(ProcessWell it) {
        sample
    }

    @Data
	static class ProcessColumn {
        val IBox<Integer> column = AOFFactory.INSTANCE.createOption
        val IBox<ProcessWell> samples = AOFFactory.INSTANCE.createSequence
    }
    def _column(ProcessColumn it) {
        column
    }
    def column(IBox<ProcessColumn> it) {
        collectMutable[it?._column ?: AbstractRule.emptyOption]
    }
    def _samples(ProcessColumn it) {
        samples
    }

    def samples2(IBox<ProcessColumn> it) {
        collectMutable[it?._samples ?: AbstractRule.emptySequence]
    }

    @Data
    static class ProcessPlate {
        val IBox<Integer> index = AOFFactory.INSTANCE.createOption
        val IBox<String> name = AOFFactory.INSTANCE.createOption
        val IBox<ProcessColumn> columns = AOFFactory.INSTANCE.createSequence
    }
    def _index(ProcessPlate it) {
        index
    }
    def _name(ProcessPlate it) {
        name
    }
    def _columns(ProcessPlate it) {
        columns
    }
    def columns(IBox<ProcessPlate> it) {
        collectMutable[it?.columns ?: AbstractRule.emptySequence]
    }

    @Data
    static class Tubes {
        val IBox<String> name = AOFFactory.INSTANCE.createOption
        val IBox<ProcessWell> samples = AOFFactory.INSTANCE.createSequence
    }
    def _name(Tubes it) {
        name
    }
    def _samples(Tubes it) {
        samples
    }

    public val __state = enumConverterBuilder(
        [_state], SampleState, ""
    )

}
