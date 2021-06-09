package ttc2021

import java.util.ArrayList
import java.util.List
import java.util.HashMap
import java.util.Map

import laboratoryAutomation.LaboratoryAutomationFactory
import laboratoryAutomation.SampleState
import laboratoryAutomation.JobRequest

import jobCollection.Job
import jobCollection.JobCollection
import jobCollection.JobStatus
import jobCollection.IncubateJob
import jobCollection.WashJob
import jobCollection.TipLiquidTransfer
import jobCollection.LiquidTransferJob


class UpdateHelper {
    val Map<Job, JobStatus> stateChanges = new HashMap
    val Map<TipLiquidTransfer, JobStatus> tipChanges = new HashMap
    val List<String> newSamples = new ArrayList

    val JobRequest jobRequest
    val JobCollection jobCollection

    new (JobRequest jobRequest, JobCollection jobCollection) {
        this.jobRequest = jobRequest
        this.jobCollection = jobCollection
    }

    def computeChanges(String change) {
        val changeSplit = change.split('_')

        if (changeSplit.get(0) == "NewSample") {
            newSamples.add(changeSplit.get(1))
            return
        }

        val stepName = changeSplit.get(0)
        val plateName = changeSplit.get(1)
        val state = changeSplit.get(2)


        // adapted from Reference solution
        jobCollection.jobs.filter[protocolStepName == stepName].forEach[ job |
            switch (job) {
                LiquidTransferJob: {
                    if (job.target.name == plateName) {
                        val wasSuccess = job.tips.map[ tip |
                            val tipSuccess = ""+state.charAt(tip.targetCavityIndex) == 'S'
                            tipChanges.put(tip, tipSuccess.toJobStatus)
                            tipSuccess
                        ].fold(true)[$0 && $1]
                        stateChanges.put(job, wasSuccess.toJobStatus)
                    }
                }
                IncubateJob: {
                    if (job.microplate.name == plateName) {
                        stateChanges.put(job, (state == "S").toJobStatus)
                    }
                }
                WashJob: {
                    if (job.microplate.name == plateName) {
                        stateChanges.put(job, (state == "S").toJobStatus)
                    }
                }
            }
        ]
    }

    def toJobStatus(Boolean status) {
        if (status) {
            JobStatus.SUCCEEDED
        }
        else {
            JobStatus.FAILED
        }
    }

    // adapted from Reference solution
    def applyChanges() {
        stateChanges.forEach[key, value |
            key.state = value
        ]

        tipChanges.forEach[key, value |
            key.status = value
        ]

        newSamples.forEach[sample | 
            jobRequest.samples.add(
                LaboratoryAutomationFactory.eINSTANCE.createSample => [
                    sampleID = sample
                    state = SampleState.WAITING
                ]
            )
        ]

        stateChanges.clear
        tipChanges.clear
        newSamples.clear
    }

}
