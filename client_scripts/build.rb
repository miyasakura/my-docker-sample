#!/usr/bin/env ruby

require 'optparse'
require 'pathname'
require 'tmpdir'
require 'fileutils'

class DockerBuilder
  def initialize(repository_url, name, buildonly, noweb)
    @repository_url = repository_url
    @name = name
    @buildonly = buildonly
    @noweb = noweb

    @current_dir = File.expand_path(File.dirname(__FILE__))
    @dir = File.join(@current_dir, "tmp", @name)
  end

  def execute
    pull unless @buildonly
    build
    push
  end

  def run(command)
    puts "exec: #{command}"
    system command
    if $? != 0
      $stderr.puts "Exit with error: status #{$?}"
      exit 1
    end
  end

  def pull
    unless Dir.exists?(@dir)
      run "git clone #{@repository_url} #{@dir}"
    else
      Dir.chdir @dir do
        run "git pull"
      end
    end
  end

  def build
    run "docker build -t localhost:5000/#{@name} #{@dir}"
  end

  def push
    run 'docker rm --force docker-registry'
    run ['docker run',
      '-d',
      '--name="docker-registry"',
      '-p 5000:5000',
      '-e REGISTRY_STORAGE_S3_ACCESSKEY=',
      '-e REGISTRY_STORAGE_S3_SECRETKEY=',
      '-e REGISTRY_STORAGE_S3_BUCKET=',
      '-e REGISTRY_STORAGE_S3_REGION=ap-northeast-1',
      '-e REGISTRY_STORAGE_S3_ROOTDIRECTORY=/v2',
      '-e REGISTRY_STORAGE=s3',
      'registry:2.0'].join(' ')
    sleep 3

    run "docker push localhost:5000/#{@name}"

    run "docker stop docker-registry"
  end
end

params = {}

opt = OptionParser.new
opt.on('-r', '--repository=VALUE', 'repository name') {|v| params[:r] = v }
opt.on('-n', '--name=VALUE', 'name for docker') {|v| params[:n] = v }
opt.on('--buildonly', 'for local souces') {|v| params[:buildonly] = v }
opt.on('--noweb', 'for local souces') {|v| params[:noweb] = v }
opt.parse!(ARGV)

unless (params[:r] && params[:n]) || (params[:n] && params[:buildonly])
  puts opt.help
  exit 255
end

builder = DockerBuilder.new(params[:r], params[:n], params[:buildonly], params[:noweb])
builder.execute

puts "success"

