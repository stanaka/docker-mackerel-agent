#!/usr/bin/env ruby
require 'pp'

class DockerPlugin
  def initialize
    @tmp_file = "/tmp/plugin.tmp"
    @prev_dat = load
  end
  
  def save(dat)
    now = Time.now.to_i
    open(@tmp_file, "w"){|f|
      dat.each {|k, v|
        f.puts [k, v, now].join("\t")
      }
    }
  end

  def load
    dat = {}
    unless File.exist?(@tmp_file)
      return dat
    end
    open(@tmp_file, "r"){|f|
      while l = f.gets
        v = l.chomp.split("\t")
        dat[v[0]] = [v[1].to_i, v[2].to_i]
      end
    }
    return dat
  end

  def output
    docker_ps = `docker ps --no-trunc`
    ps_lines = docker_ps.split("\n").map {|l| a = l.split(" "); [a[0], a[1], a[-1]]}
    names = {}
    labels = {}
    ps_lines[1..-1].each {|p| names[p[0]] = p[2]; labels[p[0]] = p[1].gsub(/[:\/\.]/, '_') }

    prefix_path = ''
    path_candidate = ['/host/sys/fs/cgroup', '/sys/fs/cgroup']
    path_candidate.each { |c|
      if Dir.exist?(c)
        prefix_path = c
        break
      end
    }

    metrics = {
      'cpuacct' => ['user', 'system'],
      'memory' => ['cache', 'rss'],
    }
    
    dat = {}
    names.each {|k,v|
      metrics.each { |metric, stat|
        content = File.open("#{prefix_path}/#{metric}/docker/#{k}/#{metric}.stat").read
        stat.each { |s|
          content =~ /#{s} (\d+)/
          # dat["docker.#{metric}."+labels[k]+"_"+names[k]+"_#{s}"] = $1.to_i
          dat["docker.#{metric}."+labels[k]+"_#{k[0,6]}_#{s}"] = $1.to_i
        }
      }
    }

    save(dat)

    now = Time.now.to_i
    outputs = {}
    dat.each {|k,v|
      if k =~ /^docker.cpu/
        if @prev_dat[k]
          outputs[k] = (dat[k] - @prev_dat[k][0]) * 60 /(now - @prev_dat[k][1])
        end
      else
        outputs[k] = dat[k]
      end
    }
    
    outputs.each {|k, v|
      puts [k, v, now].join("\t")
    }
  end
end

dp = DockerPlugin.new
dp.output

