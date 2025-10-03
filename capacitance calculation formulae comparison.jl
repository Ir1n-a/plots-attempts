using NumericalIntegration
using DataFrames
using NativeFileDialog
using CSV
using Statistics
using PrettyTables

function import_CD_data()
    println("pick a C or D file ")
    CD_file=pick_file()
    df=CSV.read(CD_file,DataFrame)

    file_name=basename(CD_file)

    CD_current=df."WE(1).Current (A)"
    CD_time=df."Corrected time (s)"
    time_to_CD=maximum(CD_time)
    CD_voltage=df."WE(1).Potential (V)"

    Potential_integral=integrate(CD_time,CD_voltage)

    return CD_current,time_to_CD,CD_voltage,Potential_integral,file_name
end

import_CD_data()

function Capacitance_calculation()
    CD_current,time_to_CD,CD_voltage,Potential_integral,file_name=import_CD_data()

    Current=mean(CD_current)
    Potential=maximum(CD_voltage)

    C_classic= (abs(Current)*time_to_CD)/Potential

    C_integral=(2*abs(Current)*Potential_integral)/(Potential^2)

    Difference=abs(C_classic-C_integral)
    Ratio=C_classic/C_integral


    header=(["File name","C_classic (F)","C_integral (F)",
    "|C_classic-C_integral| (F)","C_classic/C_integral","Current (A)","Potential (V)"])

    data=([file_name C_classic C_integral Difference Ratio Current Potential])

    destination=pick_folder()
    
    open(joinpath(destination,"$file_name-table.txt"), write=true) do io
        pretty_table(io, data;header)
    end

    pretty_table(data;header)
    
    return C_classic,C_integral,Difference,Ratio
end

Capacitance_calculation()

# add computing difference between C&D and between iterations 
# also put them in a table with the file's name attached

function Capacitance_comparison_CD()

    C_classic_C,C_integral_C,Difference_C,Ratio_C=Capacitance_calculation()
    C_classic_D,C_integral_D,Difference_D,Ratio_D=Capacitance_calculation()

    Difference_CD_classic=abs(C_classic_C-C_classic_D)
    Ratio_CD_classic=C_classic_C/C_classic_D

    Difference_CD_integral=abs(C_integral_C-C_integral_D)
    Ratio_CD_integral=C_integral_C/C_integral_D

    @show Difference_CD_classic
    @show Ratio_CD_classic
    @show Difference_CD_integral
    @show Ratio_CD_integral
end
        
Capacitance_formluae_testing_CD()


# plot the capacitance difference for all C&D iterations for TiN (et al :D)