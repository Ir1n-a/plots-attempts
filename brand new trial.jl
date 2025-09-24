using DataFrames
using CSV
using NativeFileDialog
using Plots
using SymbolicRegression
using MLJ

function import_files()
    println("pick folder of frequency data")
    fldr=pick_folder()
    freq_files=[]

    println("pick file of EIS data")
    file_EIS=pick_file()

    Current=[]
    Potential=[]
    Frequency=[]
    specific_freq=[]

    df_EIS=CSV.read(file_EIS,DataFrame)
    idx=df_EIS."-Z'' (Ω)" .<0
    Frequencies=df_EIS."Frequency (Hz)"
    removed_frequencies=Frequencies[idx]

    for file in readdir(fldr,join=true)
        
        df=CSV.read(file,DataFrame)
            if df."Frequency (Hz)"[1] ∉ removed_frequencies
                push!(freq_files,df)
            end
        push!(Current,df."Current (AC) (A)")
        push!(Potential,df."Potential (AC) (V)")
        push!(Frequency,df."Frequency (Hz)"[1])
    end

    sorted_freq=sortperm(specific_freq)

    #@show freq_files
    #@show removed_frequencies

    return Frequency,Potential,Current

    #@show freq_files
end

import_files()

function interdimensionalpolation()
    Frequency,Potential,Current=import_files()

    possible_equations=[]

    model=SRRegressor()

    for i in eachindex(Frequency)

    mach=machine(model,reshape(Potential[i], (length(Potential[i]),1)),Current[i])
    fit!(mach)

    r=report(mach)
    result=r.equations[r.best_idx]
    push!(possible_equations,result)
    end

    return possible_equations
end


interdimensionalpolation()


    import_files()

using SymbolicRegression
using MLJ

x = #input (n,1) matrix
y = # output

model = SRRegressor(
    binary_operators=[+, -, *, /],
    unary_operators=[cos],
    niterations=30
)
mach = machine(model, X, y)
fit!(mach)

r = report(mach)
r

r.equations[r.best_idx]