function RFfield(trialdata, unit=1)
    #plot the rf as sized dots over stim position
    xs=Vector{Int}(undef,0)
    ys=Vector{Int}(undef,0)
    nss=Vector{Real}(undef,0)
    ss=Vector{Real}(undef,0)
    lag=0.05

    ndx = findall(trialdata.names .== "Left")
    xs = vcat(xs, [0,-4,-8,-12,-16,-20])
    ys = vcat(ys, [0,0,0,0,0,0])
    for jj in 1:6 #event 3s
            temp=[]
            for ii in ndx
                do3 = trialdata.evnts[ii][3][jj]+lag
                push!(temp, sum(do3 .< trialdata[ii,19+((unit-1)*2)] .< do3+0.1))
            end
            push!(ss , mean(temp))
    end
    ndx = findall(trialdata.names .== "UpLeft")
    xs = vcat(xs, [0,-4,-8,-12,-16,-20])
    ys = vcat(ys, [0,4,8,12,16,20])
    for jj in 1:6 #event 3s
            temp=[]
            for ii in ndx
                do3 = trialdata.evnts[ii][3][jj]+lag
                push!(temp, sum(do3 .< trialdata[ii,19+((unit-1)*2)] .< do3+0.1))
            end
            push!(ss , mean(temp))
    end
    ndx = findall(trialdata.names .== "Up")
    xs = vcat(xs, [0,0,0,0,0,0])
    ys = vcat(ys, [0,4,8,12,16,20])
    for jj in 1:6 #event 3s
            temp=[]
            for ii in ndx
                do3 = trialdata.evnts[ii][3][jj]+lag
                push!(temp, sum(do3 .< trialdata[ii,19+((unit-1)*2)] .< do3+0.1))
            end
            push!(ss , mean(temp))
    end
    ndx = findall(trialdata.names .== "UpRight")
    xs = vcat(xs, [0,4,8,12,16,20])
    ys = vcat(ys, [0,4,8,12,16,20])
    for jj in 1:6 #event 3s
            temp=[]
            for ii in ndx
                do3 = trialdata.evnts[ii][3][jj]+lag
                push!(temp, sum(do3 .< trialdata[ii,19+((unit-1)*2)] .< do3+0.1))
            end
            push!(ss , mean(temp))
    end
    ndx = findall(trialdata.names .== "Right")
    xs = vcat(xs, [0,4,8,12,16,20])
    ys = vcat(ys, [0,0,0,0,0,0])
    for jj in 1:6 #event 3s
            temp=[]
            for ii in ndx
                do3 = trialdata.evnts[ii][3][jj]+lag
                push!(temp, sum(do3 .< trialdata[ii,19+((unit-1)*2)] .< do3+0.1))
            end
            push!(ss , mean(temp))
    end
    ndx = findall(trialdata.names .== "DownRight")
    xs = vcat(xs, [0,4,8,12,16,20])
    ys = vcat(ys, [0,-4,-8,-12,-16,-20])
    for jj in 1:6 #event 3s
            temp=[]
            for ii in ndx
                do3 = trialdata.evnts[ii][3][jj]+lag
                push!(temp, sum(do3 .< trialdata[ii,19+((unit-1)*2)] .< do3+0.1))
            end
            push!(ss , mean(temp))
    end
    ndx = findall(trialdata.names .== "Down")
    xs = vcat(xs, [0,0,0,0,0,0])
    ys = vcat(ys, [0,-4,-8,-12,-16,-20])
    for jj in 1:6 #event 3s
            temp=[]
            for ii in ndx
                do3 = trialdata.evnts[ii][3][jj]+lag
                push!(temp, sum(do3 .< trialdata[ii,19+((unit-1)*2)] .< do3+0.1))
            end
            push!(ss , mean(temp))
    end
    ndx = findall(trialdata.names .== "DownLeft")
    xs = vcat(xs, [0,-4,-8,-12,-16,-20])
    ys = vcat(ys, [0,-4,-8,-12,-16,-20])
    for jj in 1:6 #event 3s
            temp=[]
            for ii in ndx
                do3 = trialdata.evnts[ii][3][jj]+lag
                push!(temp, sum(do3 .< trialdata[ii,19+((unit-1)*2)] .< do3+0.1))
            end
            push!(ss , mean(temp))
    end
    #normalize each before adding to all units
    nss = vcat(nss, ss ./ maximum(ss))
    xy = hcat(xs,ys)
    uxy = unique(xy, dims=1)
    uss = Vector{Real}(undef, 0)
    for ii in 1:size(uxy,1)
        ndx = (uxy[ii,1] .== xs) .& (uxy[ii,2] .== ys)
        push!(uss, mean(nss[ndx]))
    end
    figure()
    scatter(uxy[:,1], uxy[:,2], (uss./maximum(uss).*10).^2)
    figure()
    scatter(uxy[:,1], uxy[:,2], uss./maximum(uss).*300)
end
