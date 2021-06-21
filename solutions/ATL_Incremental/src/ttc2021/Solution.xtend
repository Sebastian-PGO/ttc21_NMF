package ttc2021

import java.util.stream.Stream

import jobCollection.JobCollection
import laboratoryAutomation.JobRequest

interface  Solution {
    def void load(JobRequest jobRequest);
    def JobCollection initial();
    def void computeChanges(Stream<String> changes);
    def JobCollection applyChanges();
}