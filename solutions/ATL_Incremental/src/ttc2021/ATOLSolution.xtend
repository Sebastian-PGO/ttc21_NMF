package ttc2021

import java.util.stream.Stream

import jobCollection.JobCollection
import laboratoryAutomation.JobRequest

class ATOLSolution implements Solution {
    val Lab2Job transformation
    val LaboratoryChunking transfoChunking
    var JobRequest source
    var JobCollection target
    var UpdateHelper updater

    new() {
        this.transformation = new Lab2Job
        this.transfoChunking = new LaboratoryChunking
        this.transfoChunking.LAMM.tubesCache = this.transformation.LAMM.tubesCache
        this.transfoChunking.LAMM.processPlatesCache = this.transformation.LAMM.processPlatesCache
    }

    override void load(JobRequest jobRequest) {
        this.source = jobRequest
    }

    override JobCollection initial() {
        transfoChunking.refine(source.eResource)
        target = transformation.JobRequest(this.source).t
        this.updater = new UpdateHelper(this.source, target)
        return target
    }
    override void computeChanges(Stream<String> changes) {
        changes.forEach[
            updater.computeChanges(it)
        ]
    }

    override JobCollection applyChanges() {
        updater.applyChanges

        return target
    }
}
