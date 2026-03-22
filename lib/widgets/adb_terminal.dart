import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_card.dart';

class AdbTerminal extends StatefulWidget {
  const AdbTerminal({Key? key}) : super(key: key);

  @override
  State<AdbTerminal> createState() => _AdbTerminalState();
}

class _AdbTerminalState extends State<AdbTerminal> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<String> _terminalLines = [
    r'$ adb shell',
    'android:/ \$ sh /storage/emulated/0/shizuku/starter.sh',
    'Shizuku is running (pid 2847)',
    'android:/ \$ ',
  ];

  static const Color accentColor = Color(0xFF00FFB2);

  final Map<String, List<String>> _commandResponses = {
    'ps': [
      'USER           PID  PPID     VSZ    RSS WCHAN            ADDR S NAME',
      'root             1     0 1234567  45678 SyS_epoll        0000 S init',
      'root           247     1  987654  23456 poll_schedule 0000 S /system/bin/adbd',
      'system         512     1 4567890  12345 epoll_wait    0000 S system_server',
      'u0_a123        678   512 3456789  98765 epoll_wait    0000 S com.android.launcher',
      'android:/ \$ ',
    ],
    'ls': [
      'acct                 config               lost+found           sbin',
      'apex                 data                 metadata             sdcard',
      'bin                  debug_ramdisk        mnt                  sys',
      'boot.img             dev                  proc                 system',
      'bugreports           etc                  product              vendor',
      'cache                init                 root',
      'android:/ \$ ',
    ],
    'getprop': [
      '[dalvik.vm.appimageformat]: [lz4]',
      '[dalvik.vm.dex2oat-cpu-set]: []',
      '[dalvik.vm.dex2oat-threads]: [4]',
      '[dalvik.vm.heapgrowthlimit]: [512m]',
      '[dalvik.vm.heapmaxfree]: [8m]',
      '[dalvik.vm.heapminfree]: [512k]',
      '[dalvik.vm.heapsize]: [1g]',
      '[dalvik.vm.heapstartsize]: [8m]',
      '[dalvik.vm.heaptargetutilization]: [0.75]',
      '[dalvik.vm.hot-startup-method-samples]: [1000]',
      'android:/ \$ ',
    ],
    'getprop ro.product.model': [
      'Pixel 6 Pro',
      'android:/ \$ ',
    ],
    'top': [
      'Tasks: 245 total,   2 running, 243 sleeping',
      'Mem:   3.8G total,   2.1G used,   1.7G free',
      'PID  USER     PR  NI VIRT  RES  SHR S %CPU %MEM TIME+ COMMAND',
      '512  system   -20  0 4.5G  750M 300M S 25.3  19.4  45:21 system_server',
      '678  u0_a456  -18  0 2.8G  650M 250M S  8.2  16.8  12:34 com.android.chrome',
      '890  u0_a789  -10  0 1.9G  480M 180M S  3.1   12.5   5:42 com.spotify.music',
      'android:/ \$ ',
    ],
    'dumpsys battery': [
      'Current Battery Service state:',
      '  AC powered: false',
      '  USB powered: true',
      '  Wireless powered: false',
      '  status: 2',
      '  health: 2',
      '  present: true',
      '  level: 92',
      '  scale: 100',
      '  voltage: 4287',
      '  temperature: 320',
      '  technology: Li-ion',
      'android:/ \$ ',
    ],
    'netstat': [
      'Active Internet connections (only servers)',
      'Proto Recv-Q Send-Q Local Address           Foreign Address         State',
      'tcp        0      0 127.0.0.1:5037          0.0.0.0:*               LISTEN',
      'tcp        0      0 192.168.1.100:5555      0.0.0.0:*               LISTEN',
      'tcp        0      0 127.0.0.1:8088          0.0.0.0:*               LISTEN',
      'udp        0      0 0.0.0.0:5353            0.0.0.0:*',
      'udp        0      0 192.168.1.100:67        0.0.0.0:*',
      'android:/ \$ ',
    ],
    'ifconfig': [
      'lo: flags=73<UP,LOOPBACK,RUNNING>',
      '        inet 127.0.0.1  netmask 255.0.0.0',
      'wlan0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>',
      '        inet 192.168.1.100  netmask 255.255.255.0  broadcast 192.168.1.255',
      '        inet6 fe80::1a2b:3c4d:5e6f:7890  prefixlen 64',
      '        ether aa:bb:cc:dd:ee:ff',
      'android:/ \$ ',
    ],
    'uname': [
      'Linux localhost 5.4.0-42-generic #46-Ubuntu SMP Fri Jul 10 00:24:02 UTC 2020 aarch64 GNU/Linux',
      'android:/ \$ ',
    ],
    'id': [
      'uid=0(root) gid=0(root) groups=0(root)',
      'android:/ \$ ',
    ],
    'help': [
      'Available Shizuku Shell Commands:',
      '  ps              - List running processes',
      '  ls              - List directory contents',
      '  getprop         - Get system properties',
      '  top             - Show running processes (realtime)',
      '  dumpsys         - Dump system service info',
      '  netstat         - Show network connections',
      '  ifconfig        - Show network interfaces',
      '  uname           - Show system information',
      '  id              - Show current user info',
      '  help            - Show this help message',
      'android:/ \$ ',
    ],
  };

  void _handleSubmit(String command) {
    if (command.trim().isEmpty) return;

    setState(() {
      if (_terminalLines.isNotEmpty && _terminalLines.last == 'android:/ \$ ') {
        _terminalLines.removeLast();
      }
      _terminalLines.add('android:/ \$ $command');

      final trimmedCommand = command.trim();
      if (_commandResponses.containsKey(trimmedCommand)) {
        _terminalLines.addAll(_commandResponses[trimmedCommand]!);
      } else {
        _terminalLines.add('sh: $trimmedCommand: command not found');
        _terminalLines.add('android:/ \$ ');
      }
    });

    _inputController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _clearTerminal() {
    setState(() {
      _terminalLines
        ..clear()
        ..addAll([
          r'$ adb shell',
          'android:/ \$ ',
        ]);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Container(
              constraints: const BoxConstraints(minHeight: 220, maxHeight: 220),
              decoration: BoxDecoration(
                color: const Color(0xFF101216),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF232831),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _terminalLines.length,
                  itemBuilder: (context, index) {
                    final line = _terminalLines[index];
                    return Text(
                      line,
                      style: GoogleFonts.sourceCodePro(
                        color: accentColor,
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF101216),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF232831),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    'android:/ \$ ',
                    style: GoogleFonts.sourceCodePro(
                      color: accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    onSubmitted: _handleSubmit,
                    style: GoogleFonts.sourceCodePro(
                      color: accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      hintText: 'Type command...',
                      hintStyle: GoogleFonts.sourceCodePro(
                        color: accentColor.withValues(alpha: 0.3),
                        fontSize: 12,
                      ),
                    ),
                    cursorColor: accentColor,
                  ),
                ),
                TextButton(
                  onPressed: _clearTerminal,
                  child: Text(
                    'Clear',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
