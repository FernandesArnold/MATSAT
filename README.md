# MATSAT
MATSAT- MATlab Structural Analysis Toolbox is a qualitative analysis toolbox that performs structural observability and structural monitorability assessments for a BG model for various sensor combinations.

All functions used by MATSAT are stored in the "lib" folder.
Bond Graph 20-Sim model files have the .emx extension and are stored in the "models" folder. The hoist_model.m provides a template to users who want to use MATSAT but don't have access to 20-Sim.
The "examples" folder demonstrates the use of "lib" functions for structural analysis.

examples/mainfile_structural_observability.m generates a structural observability table for a given BG.
examples/mainfile_structural_monitorability.m generates a fault signature matrix for a given BG. It does this for various sensor combinations. This file also computes other information such as structural isolability and sensor redundancy.
