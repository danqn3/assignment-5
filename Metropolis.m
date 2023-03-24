classdef Metropolis
    properties
        samples
    end
    
    properties (Access = private)
        logTarget
        state
        sigma
        acceptCount
        totalCount
    end
    
    methods
        function self = Metropolis(logTarget, initialState)
            self.logTarget = logTarget;
            self.state = initialState;
            self.sigma = 1;
            self.acceptCount = 0;
            self.totalCount = 0;
        end
        
        function self = adapt(self, blockLengths)
            targetRate = 0.4;
            for blockLength = blockLengths
                acceptances = 0;
                for i = 1:blockLength
                    proposal = self.state + self.sigma * randn;
                    if self.accept(proposal)
                        self.state = proposal;
                        acceptances = acceptances + 1;
                    end
                    self.totalCount = self.totalCount + 1;
                end
                acceptanceRate = acceptances / blockLength;
                if acceptanceRate > targetRate
                    self.sigma = self.sigma * exp(1 / sqrt(self.totalCount));
                else
                    self.sigma = self.sigma / exp(1 / sqrt(self.totalCount));
                end
                self.acceptCount = self.acceptCount + acceptances;
            end
        end
        
        function self = sample(self, n)
            self.samples = zeros(n, 1);
            for i = 1:n
                proposal = self.state + self.sigma * randn;
                if self.accept(proposal)
                    self.state = proposal;
                end
                self.samples(i) = self.state;
                self.totalCount = self.totalCount + 1;
            end
        end
        
        function summ = summary(self)
            sortedSamples = sort(self.samples);
            m = mean(sortedSamples);
            ci = [sortedSamples(round(0.025 * length(sortedSamples))), sortedSamples(round(0.975 * length(sortedSamples)))];
            summ.mean = m;
            summ.c025 = ci(1);
            summ.c975 = ci(2);
        end
    end
    
    methods (Access = private)
        function yesno = accept(self, proposal)
            logRatio = self.logTarget(proposal) - self.logTarget(self.state);
            if logRatio > log(rand)
                self.acceptCount = self.acceptCount + 1;
                yesno = true;
            else
                yesno = false;
            end
        end
    end
end
