using CSV
using NativeFileDialog
using Plots
using SymbolicRegression
using MLJ
using DataFrames

function import_EIS()

    println("import the EIS")
    EIS_file=pick_file()
    df=CSV.read(EIS_file,DataFrame)

    idx= 1000 .> df."-Z'' (Ω)" .>0
    Zre=df."Z' (Ω)"[idx]
    Zimg=df."-Z'' (Ω)"[idx]
    Frequency=df."Frequency (Hz)"[idx]
    Z=df."Z (Ω)"[idx]
    Phase=df."-Phase (°)"[idx]

    return Z,Frequency
end

function interpolationqm()
    Z,Frequency=import_EIS()

    possible_equations=[]

    model=SRRegressor()

    mach=machine(model,reshape(Frequency,(length(Frequency),1)),Z)
    fit!(mach)

    r=report(mach)

    result=r.equations[r.best_idx]
    push!(possible_equations,result)


return possible_equations
end

interpolationqm()