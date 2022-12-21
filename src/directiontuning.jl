function directiontuning(trialdata, unit)
    #using Plots
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

    #break into conditions
    Tnames = sort(unique(trialdata.names))
    figure()
    #spikes per condition
    dorder = [6,3,2,1,4,7,8,9]
    Tspikes = Array{Any}(undef, size(Tnames))
    #h = copy(Tspikes)
    uu = 0
    for T in Tnames
        uu+=1
        ndx = findall(x->x==T, trialdata.names)
        vals=[]
        for ii in ndx
            tmp = trialdata[ii,utimes] .- trialdata.evnts[ii][1] .- trialdata.startTime[ii][1]/1000
            push!(vals, collect(skipmissing(tmp)))
        end
        spikes=[]
        for ii in vals, jj in ii
            push!(spikes,jj)
        end
        Tspikes[uu] = spikes

        #h[uu] = Plots.histogram(spikes,bins=length(0:0.01:3), title = "$(Tnames[uu])") #0:interval:max
        subplot(3,3,dorder[uu])
        plt.hist(spikes, length(0:0.01:3))
        PyPlot.title("$(Tnames[uu])")
    end

    #look at waveforms
    waves=zeros(0);
    f=1
    while isnan(length(collect(skipmissing(trialdata[f,uwaves])))/length(collect(skipmissing(trialdata[f,utimes]))))
        f+=1
    end
    nspikes = length(collect(skipmissing(trialdata[f,utimes])))
    if nspikes == 0
        nspikes = NaN #to prevent dividing by 0, if a condition has no spikes
    end
    if length(collect(skipmissing(trialdata[f,uwaves])))%nspikes == 0 #each spike has a waveform
        try
            wlength = Int(length(collect(skipmissing(trialdata[f,uwaves])))/length(collect(skipmissing(trialdata[f,utimes]))))
            tdir = sort(unique(trialdata.tarDir))
            init = zeros(size(tdir))
            if wlength>0 #in case unit didn't fire during dtuning but was otherwise useable
                for ii in 1:size(trialdata,1)
                    #need to reshape trialdata as each wave is a row but the vector goes down columns first
                    hld = reshape(collect(skipmissing(trialdata[ii,uwaves])), div(length(collect(skipmissing(trialdata[ii,uwaves]))),wlength), wlength)' #each wave a column
                    hld = reshape(hld,length(hld),1)    #vector of ordered waves
                    append!(waves, hld)
                end
                waves = reshape(waves, wlength, div(size(waves,1),wlength));
                #push!(h, Plots.plot(waves));  #waveform in middle

                #Plots.plot(h[4],h[3],h[2],h[5],h[9],h[1],h[6],h[7],h[8], layout=(3,3), label="")
                subplot(3,3,5)
                PyPlot.plot(waves);
                #get direction tuning curve for initiation
                #fit guassian to data
                #loop through directions and count spikes in initial window
                window = 0.1
                lag = 0.05
                for dd in 1:length(tdir)
                    ndx = findall(x->x==tdir[dd], trialdata.tarDir)
                    if isempty(Tspikes[dd])
                        init[dd] = 0
                        continue
                    end
                    #spike count / number of trials / time block for spikes per second
                    init[dd] = sum( lag .< Tspikes[dd] .< window+lag) / length(ndx) / window
                end
                figure()
                scatter(tdir, init)
                #plot and fit gauss, slide/offset dir if needed to get good fit
                #show peak and valley in pref and anti
            end
        catch
            println("Could not reshape, spikes removed?")
        end
    else
        tdir = sort(unique(trialdata.tarDir))
        init = zeros(size(tdir))
        window = 0.1
        lag = 0.05
        for dd in 1:length(tdir)
            ndx = findall(x->x==tdir[dd], trialdata.tarDir)
            if isempty(Tspikes[dd])
                init[dd] = 0
                continue
            end
            #spike count / number of trials / time block for spikes per second
            init[dd] = sum( lag .< Tspikes[dd] .< window+lag) / length(ndx) / window
        end
        figure()
        scatter(tdir, init)
    end
    return tdir, init
end
