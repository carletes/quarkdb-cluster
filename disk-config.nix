{ lib
, ...
}:
{
  disko.devices = {
    disk.system = {
      device = lib.mkDefault "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
          esp = {
            name = "ESP";
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "system";
            };
          };
        };
      };
    };

    disk.data = {
      device = lib.mkDefault "/dev/sdb";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          data = {
            name = "data";
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "data";
            };
          };
        };
      };
    };

    lvm_vg = {
      system = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "xfs";
              mountpoint = "/";
              mountOptions = [
                "defaults"
              ];
            };
          };
        };
      };

      data = {
        type = "lvm_vg";
        lvs = {
          data = {
            size = "50%FREE";
            content = {
              type = "filesystem";
              format = "xfs";
              mountpoint = "/var/lib/quarkdb";
              mountOptions = [
                "defaults"
              ];
            };
          };
        };
      };
    };
  };
}
