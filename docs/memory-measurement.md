# Memory measurement
TASK_VM_INFO phys_footprint measures the app process. A 100 ms sampler retains
only its maximum, plus baseline before load and endpoint after warm inference.
This is a sampled peak, not an exact peak or model-only memory. Brief spikes may
be missed. Apple speech model execution occurs outside the app process and its
memory is not included. Failed task_info calls produce Not available.
