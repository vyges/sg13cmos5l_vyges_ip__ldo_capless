
# CACE Summary for ldo_capless

**netlist source**: schematic

|      Parameter       |         Tool         |     Result      | Min Limit  |  Min Value   | Typ Target |  Typ Value   | Max Limit  |  Max Value   |  Status  |
| :------------------- | :------------------- | :-------------- | ---------: | -----------: | ---------: | -----------: | ---------: | -----------: | :------: |
| Output voltage       | ngspice              | vout_op              |           1.1 V |    1.209 V |        1.2 V |    1.209 V |        1.3 V |    1.211 V |   Pass ✅    |
| Line regulation      | ngspice              | linereg              |             any | 0.382 mV/V |          any | 0.385 mV/V |       5 mV/V | 0.435 mV/V |   Pass ✅    |
| Load regulation      | ngspice              | loadreg              |             any |   0.214 mV |          any |   0.268 mV |        20 mV |   0.787 mV |   Pass ✅    |


## Plots
