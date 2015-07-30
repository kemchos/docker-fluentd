module Fluent
  class DockerFilter < Filter
    Fluent::Plugin.register_filter("docker", self)

    def initialize
      require "socket"
      require "docker"
      super
    end

    def configure(conf)
      super
      @id = conf["id"]
      @hostname = Socket.gethostname
    end

    def filter(tag, time, record)
      begin
        container = getContainer(tag, @id)
        if container
          name = container.json["Name"]
          record["container_name"] = name[0] == "/" ? name[1..-1] : name
          record["container_image"] = container.json["Config"]["Image"]
        end
        record["host"] = @hostname
      rescue => e
        log.warn "failed to docker process events", :error_class => e.class, :error => e.message
        log.warn_backtrace
      end
      record
    end

    private

    def getContainer(tag, id)
      container = nil
      id.match(/\$\{tag_parts\[(\d+)\]\}/) do |m|
        tag_parts = tag.split(".")
        id = tag_parts[m[1].to_i]
        container = Docker::Container.get(id)
      end
      container
    end
  end
end