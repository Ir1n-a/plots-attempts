using NumericalIntegration
using DataFrames
using NativeFileDialog
using CSV
using Statistics

function import_CD_data()
    println("pick a C or D file ")
    CD_file=pick_file()
    df=CSV.read(CD_file,DataFrame)

    CD_current=df."WE(1).Current (A)"
    CD_time=df."Corrected time (s)"
    time_to_CD=maximum(CD_time)
    CD_voltage=df."WE(1).Potential (V)"

    Potential_integral=integrate(CD_time,CD_voltage)

    return CD_current,time_to_CD,CD_voltage,Potential_integral
end

function Capacitance_formulae_testing()
    CD_current,time_to_CD,CD_voltage,Potential_integral=import_CD_data()

    C_classic= (mean(CD_current)*time_to_CD)/maximum(CD_voltage)

    C_integral=(2*mean(CD_current)*Potential_integral)/(maximum(CD_voltage)^2)

    @show C_classic
    @show C_integral
    @show C_classic-C_integral
    @show C_classic/C_integral
end
    
Capacitance_formulae_testing()