function FRatPSforpl(trialdata, unit, coh=100, plt=true)
    #determine which column in units
    cnames = names(trialdata)
    nn=0

    for ii in 1:length(cnames)
        i=ii
        global i
        if occursin("spike", string(cnames[ii]))
            nn+=0.5
        end
        if nn >= unit
            break
        end
    end
    utimes = i-1
    uwaves = i

    #only look at 100% coherence for initiation
    td = trialdata[trialdata.coherence .== coh,:]
    tdir=sort(unique(trialdata.tarDir))
    #speeds=sort(unique(trialdata.tarSp))
    simptarSp=Vector{String}(undef , 0)
    for ii in 1:length(td.names)
       a = findfirst("sp", td.names[ii])
       suba = td.names[ii][a[end]+1:end]
       b = findfirst("_", suba)
       c = findfirst("+", suba)
       if isnothing(b) && isnothing(c)
           push!(simptarSp, suba)
       elseif ~isnothing(b)
           push!(simptarSp, suba[1:b[1]-1])
       elseif ~isnothing(c)
           push!(simptarSp, suba[1:c[1]-1])
       end
    end
    simptarSp = [parse(Int, x) for x in simptarSp]
    speeds = sort(unique(simptarSp))
    window = 0.1
    lag = 0.05
    pstune = Vector{Real}(undef,0)
    astune = Vector{Real}(undef,0)
    for dd in tdir
        #figure()
        tempD = td[td.tarDir .== dd, :]
        subtarSp = simptarSp[td.tarDir .== dd]
        stune = Vector{Real}(undef,0)
        for ss in speeds
            tempS = tempD[subtarSp .== ss, :]
            spks = 0;
            for ii in 1:size(tempS,1)
                sptime = collect(skipmissing(tempS[ii,utimes]))
                sptime = sptime .- tempS.evnts[ii][1] .- tempS.startTime[ii]/1000
                if isempty(sptime)
                    continue
                end
                spks += sum( lag .< sptime .< window+lag) / window
                #println(spks)
            end
            spks /= size(tempS,1)
            push!(stune, spks)
        end
        #determine preferred/anti
        if occursin("P",tempD.names[1])
            pstune = copy(stune)
        elseif occursin("A",tempD.names[1])
            astune = copy(stune)
        end
        #scatter([1:length(speeds)], stune)#change label to speeds
    end

    if maximum(astune-pstune) > maximum(pstune-astune) #if preferred and antipreferred is actually flipped
        ahld = copy(pstune)
        phld = copy(astune)
        pstune = copy(phld)
        astune = copy(ahld)
    end
    if plt
        figure()
        subplot(1,3,1)
        scatter([1:length(speeds)], pstune - astune)
    end

    #guassian model with pseudo log speeds
    model(x, p) = p[1] * exp.(-1 .*((x.-p[2]).^2) ./ (2 .*p[3].^2) )#p[1] * exp.(-1 .*((x.-p[2])./p[3]).^2)
    tdata = [1,2,3,4,5]
    ydata = pstune
    p0 = [0.5, 0.5, 0.5]
    fit = curve_fit(model, tdata, ydata, p0)
    param = fit.param

    fit = curve_fit(model, tdata, ydata, param) #run with initialized params at least once for more accurate fit
    param = fit.param
    fit = curve_fit(model, tdata, ydata, param)
    param = fit.param
    fit = curve_fit(model, tdata, ydata, param)
    param = fit.param
    #title(param[:])  #future warning for some reason, took forever to find
    rng = 1:0.01:5
    mm = model(rng, param);
    if plt
        subplot(1,3,2)
        scatter(tdata,ydata)
        plot(rng, mm)
    end

    ndx=findfirst(maximum(mm) .== mm)
    b = log(32/2)/(5-1);
    a = 2/exp(b*1);
    prefSp = a*exp(b*rng[ndx])
    #figure()
    #scatter(prefSp, maximum(mm))
    FRp = maximum(mm)

    ydata = astune .+ 0.01
    fit = curve_fit(model, tdata, ydata, p0) #can't handle any 0s in ydata for the time being
    param = fit.param

    fit = curve_fit(model, tdata, ydata, param) #run with initialized params at least once for more accurate fit
    param = fit.param
    fit = curve_fit(model, tdata, ydata, param)
    param = fit.param
    fit = curve_fit(model, tdata, ydata, param)
    param = fit.param

    mm = model(rng, param);
    if plt
        subplot(1,3,3)
        scatter(tdata,ydata)
        plot(rng, mm)
    end

    ndx=findfirst(maximum(mm) .== mm)
    prefSa = a*exp(b*rng[ndx])
    #figure()
    #scatter(prefSa, maximum(mm))
    FRa = maximum(mm)

    return prefSp, FRp, prefSa, FRa
end
