# hosts/lapbottom/disko.nix
#
# GPT -> [ESP 1G vfat] [LUKS "cryptroot" -> btrfs with subvolumes]
#
# disko owns fileSystems.* and boot.initrd.luks.* for this host, so those
# are deliberately absent from hardware-configuration.nix.
{
  disko.devices.disk.main = {
    type = "disk";

    # VERIFY with `lsblk` from the installer before running disko.
    # Prefer /dev/disk/by-id/nvme-... if you have more than one drive.
    # device = "/dev/nvme0n1";
    device = "/dev/disk/by-id/nvme-SAMSUNG_MZVL8512HFLU-00BH1_S7TANF3Y330224";

    content = {
      type = "gpt";
      partitions = {
        ESP = {
          # 1G: lanzaboote's signed UKIs are much larger than plain
          # systemd-boot entries and you want room for several generations.
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";

            # Interactive passphrase prompt at format time.
            askPassword = true;

            settings = {
              # SSD TRIM through the encryption layer.
              allowDiscards = true;

              # Enable AFTER secure boot is on and you've run:
              #   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p2
              # crypttabExtraOpts = [ "tpm2-device=auto" ];
            };

            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@log" = {
                  mountpoint = "/var/log";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "@swap" = {
                  # Swapfile for memory pressure only. Hibernation needs a
                  # resume offset and kernel params -- not configured here.
                  # Delete this block entirely if you'd rather run without swap.
                  mountpoint = "/.swapvol";
                  swap.swapfile.size = "16G";
                };
              };
            };
          };
        };
      };
    };
  };
}
