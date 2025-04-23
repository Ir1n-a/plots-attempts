using Plots
using CSV
using DataFrames
using NativeFileDialog
using DelimitedFiles
using DataInterpolations

function sort_files()
    fl=pick_folder()
    files_vector=[]
    for file in readdir(fl,join=true)
            if split(basename(file),".")[end]=="txt" || split(basename(file),".")[end]=="html"
                continue
            else
                push!(files_vector,file)
            end
        end
    return files_vector

end

function sort_files_for_Real()
    F=[]
    files_labels=[]
    files_vector=sort_files()
    permutation_file=pick_file()

    @show readdlm(permutation_file)

    permutation_vector=Int.(readdlm(permutation_file, ' '))
    print(permutation_vector)
    final_files=files_vector[permutation_vector]

    

    for file in final_files
        df=CSV.read(file,DataFrame)
        push!(F,df)
        push!(files_labels,basename(file))
    end
    @show files_vector
    @show files_labels
    @show permutedims(final_files)
    #return F
    
end

sort_files()
sort_files_for_Real()

