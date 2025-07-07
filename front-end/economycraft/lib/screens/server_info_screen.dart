import 'package:economycraft/services/supabase_helper.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:economycraft/classes/admin_message.dart';

class ServerInfoScreen extends StatefulWidget {
  const ServerInfoScreen({super.key});

  @override
  State<ServerInfoScreen> createState() => _ServerInfoScreenState();
}

class _ServerInfoScreenState extends State<ServerInfoScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  final DateTime _serverStartDate = DateTime.utc(
    2025,
    7,
    11,
  ); // Server start date

  List<AdminMessage> _adminMessages = [];

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _fetchAdminMessages(); // Fetch admin messages on init
  }

  // Determine if server is on for a given day
  bool _isServerOnDay(DateTime day) {
    if (day.isBefore(_serverStartDate)) {
      return false; // Server not active before start date
    }

    // Calculate days since server start
    final difference = day.difference(_serverStartDate).inDays;

    // Server cycle: 2 days on, 2 days off
    final cycleDayIndex = difference % 4;

    // Days 0 and 1 in the cycle are "on" days
    return cycleDayIndex == 0 || cycleDayIndex == 1;
  }

  // Get server status text for a given day
  String _getServerStatusText(DateTime day) {
    if (day.isBefore(_serverStartDate)) {
      return 'Not yet launched';
    }
    return _isServerOnDay(day) ? 'Server Online' : 'Server Offline';
  }

  // Get list of events for a day
  List<String> _getEventsForDay(DateTime day) {
    // Return server status as an event
    return [_getServerStatusText(day)];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Server Info',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 229, 255, 252),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 28),
          onPressed: () {
            context.go('/home');
          },
        ),
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/background_images/quartz_background.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Container(
                width: screenWidth > 1200 ? 1100 : screenWidth * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 229, 255, 252),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.calendar_month,
                              size: 28,
                              color: Color.fromARGB(255, 74, 237, 217),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Server Schedule',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 74, 237, 217),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Check when the server is online',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),

                          // Legend
                          Row(
                            children: [
                              _buildLegendItem(
                                'Server Online',
                                const Color.fromARGB(255, 23, 221, 97),
                              ),
                              const SizedBox(width: 16),
                              _buildLegendItem(
                                'Server Offline',
                                Colors.redAccent,
                              ),
                              const SizedBox(width: 16),
                              _buildLegendItem(
                                'Selected Day',
                                const Color.fromARGB(255, 74, 237, 217),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Calendar and info section
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child:
                          screenWidth > 900
                              ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 3, child: _buildCalendar()),
                                  const SizedBox(width: 24),
                                  Expanded(flex: 2, child: _buildInfoSection()),
                                ],
                              )
                              : Column(
                                children: [
                                  _buildCalendar(),
                                  const SizedBox(height: 24),
                                  _buildInfoSection(),
                                ],
                              ),
                    ),

                    // Admin Messages Section
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    229,
                                    255,
                                    252,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.announcement,
                                  color: Color.fromARGB(255, 74, 237, 217),
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'Messages from Admins',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          ..._buildAdminMessages(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.month,
        eventLoader: _getEventsForDay,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: CalendarStyle(
          // Customize the appearance of days
          defaultDecoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8),
          ),
          weekendDecoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8),
          ),
          selectedDecoration: BoxDecoration(
            color: const Color.fromARGB(255, 74, 237, 217),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8),
          ),
          todayDecoration: BoxDecoration(
            color: const Color.fromARGB(255, 74, 237, 217).withOpacity(0.5),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8),
          ),
          // Custom day cell based on server status
          defaultTextStyle: const TextStyle(color: Colors.black),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          todayTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),

          // Mark days with events
          markersMaxCount: 1,
          markerDecoration: BoxDecoration(
            color: const Color.fromARGB(0, 255, 82, 82),
            shape: BoxShape.circle,
          ),
          markersAnchor: 0.7,

          // Custom day cell builder
          cellMargin: const EdgeInsets.all(4),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
          weekendStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          leftChevronIcon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 229, 255, 252),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.chevron_left,
              color: Color.fromARGB(255, 74, 237, 217),
            ),
          ),
          rightChevronIcon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 229, 255, 252),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.chevron_right,
              color: Color.fromARGB(255, 74, 237, 217),
            ),
          ),
        ),
        calendarBuilders: CalendarBuilders(
          // Custom day builder to color the cells based on server status
          defaultBuilder: (context, day, focusedDay) {
            return _buildCalendarDayCell(day);
          },
          todayBuilder: (context, day, focusedDay) {
            return _buildCalendarDayCell(day, isToday: true);
          },
          selectedBuilder: (context, day, focusedDay) {
            return _buildCalendarDayCell(day, isSelected: true);
          },
        ),
      ),
    );
  }

  Widget _buildCalendarDayCell(
    DateTime day, {
    bool isToday = false,
    bool isSelected = false,
  }) {
    final isServerOn = _isServerOnDay(day);
    final serverStatus = _getServerStatusText(day);

    Color backgroundColor;
    Color textColor;
    FontWeight fontWeight = FontWeight.normal;

    if (isSelected) {
      backgroundColor = const Color.fromARGB(255, 74, 237, 217);
      textColor = Colors.white;
      fontWeight = FontWeight.bold;
    } else if (isToday) {
      backgroundColor = const Color.fromARGB(
        255,
        74,
        237,
        217,
      ).withOpacity(0.3);
      textColor = Colors.black;
      fontWeight = FontWeight.bold;
    } else if (day.isBefore(_serverStartDate)) {
      backgroundColor = Colors.grey[200]!;
      textColor = Colors.grey[500]!;
    } else if (isServerOn) {
      backgroundColor = const Color.fromARGB(255, 23, 221, 97).withOpacity(0.2);
      textColor = const Color.fromARGB(255, 23, 221, 97);
    } else {
      backgroundColor = Colors.redAccent.withOpacity(0.1);
      textColor = Colors.redAccent;
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Text(
                '${day.day}',
                style: TextStyle(color: textColor, fontWeight: fontWeight),
              ),
            ),
          ),
          if (!day.isBefore(_serverStartDate))
            Positioned(
              bottom: 2,
              right: 0,
              left: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isServerOn ? Icons.circle : Icons.circle_outlined,
                    size: 6,
                    color: textColor,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected day info
          Text(
            DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 74, 237, 217),
            ),
          ),
          const SizedBox(height: 16),

          // Server status for selected day
          _buildStatusCard(),

          const SizedBox(height: 24),

          // Server Info
          const Text(
            'Server Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Server cycle info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Server Cycle:',
                  '2 days ON, 2 days OFF',
                  icon: Icons.repeat,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Days Since Launch:',
                  '${DateTime.now().difference(_serverStartDate).inDays} days',
                  icon: Icons.rocket_launch,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Server Time:',
                  '06:00 - 06:00',
                  icon: Icons.access_time,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Server Location:',
                  'North America',
                  icon: Icons.location_on,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final isServerOn = _isServerOnDay(_selectedDay);
    final bool isBeforeLaunch = _selectedDay.isBefore(_serverStartDate);

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isBeforeLaunch) {
      statusColor = Colors.grey;
      statusText = 'Not Yet Launched';
      statusIcon = Icons.upcoming;
    } else if (isServerOn) {
      statusColor = const Color.fromARGB(255, 23, 221, 97);
      statusText = 'Server Online';
      statusIcon = Icons.cloud_done;
    } else {
      statusColor = Colors.redAccent;
      statusText = 'Server Offline';
      statusIcon = Icons.cloud_off;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              if (!isBeforeLaunch)
                Text(
                  isServerOn
                      ? 'The server is open for play'
                      : 'The server is closed today',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {required IconData icon}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 229, 255, 252),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color.fromARGB(255, 74, 237, 217),
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAdminMessages() {
    if (_adminMessages.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Icon(
                  Icons.mark_email_unread_outlined,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No messages from admins',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    final sortedMessages = List<AdminMessage>.from(_adminMessages)
      ..sort((a, b) => b.date.compareTo(a.date));

    return sortedMessages.map((message) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color:
              message.important
                  ? const Color.fromARGB(255, 255, 244, 236)
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                message.important
                    ? const Color.fromARGB(255, 255, 149, 0)
                    : Colors.grey[200]!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    message.important
                        ? const Color.fromARGB(255, 255, 244, 236)
                        : Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    message.important ? Icons.campaign : Icons.message,
                    color:
                        message.important
                            ? const Color.fromARGB(255, 255, 149, 0)
                            : Colors.grey[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            message.important
                                ? const Color.fromARGB(255, 255, 149, 0)
                                : Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy').format(message.date),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Message content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                message.content,
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
            ),

            // Message footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 16,
                    color: Color.fromARGB(255, 74, 237, 217),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    message.authorName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 74, 237, 217),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Future<List<AdminMessage>> _fetchAdminMessages() async {
    try {
      final messages = await SupabaseHelper.getAdminMessages();
      setState(() {
        _adminMessages = messages;
      });
      print('Fetched ${messages.length} admin messages');
      return messages;
    } catch (e) {
      print('Error fetching admin messages: $e');
      return [];
    }
  }
}



// Class to represent admin messages (will be replaced with model from Supabase)

