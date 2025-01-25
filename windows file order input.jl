#=because windows only considers the first character/number
to determine the input files order, I need to introduce a step
where the order is established after input by the user,
preferably not in an annoying, convoluted way :D. I will come up
with something separately over here before transferring it to the destination
program, yeah=# 

using DataFrames
using NativeFileDialog
using CSV

function folder_input()
    fld=pick_folder()
    v=[]
    u=[]
    for file in readdir(fld)
        push!(v,file)
        push!(u,file)
    end
    v[3]=u[4]
    v[4]=u[8]
    v[5]=u[3]
    v[8]=u[5]
    return v
end

folder_input()

#=testing the order, yes the problem is still there.
A first solution would be to pick an ordering vector
and manually setting the correspondence between the file and
its decided rank=#


#=I'm currently storing the files in a vector and 
I have to figure out a way to order them in the 
desired order=#