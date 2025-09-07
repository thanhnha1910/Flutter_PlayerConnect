import 'package:flutter/material.dart';
import 'dart:async';
import '../../data/datasources/chat_remote_data_source.dart';
import '../../core/di/injection.dart';
import '../../core/storage/secure_storage.dart';

class ChatSettingsModal extends StatefulWidget {
  final String roomId;
  final String roomName;
  final VoidCallback? onChatDeleted;
  final VoidCallback? onLeftRoom;
  final Function(List<dynamic>)? onMembersUpdated;

  const ChatSettingsModal({
    super.key,
    required this.roomId,
    required this.roomName,
    this.onChatDeleted,
    this.onLeftRoom,
    this.onMembersUpdated,
  });

  @override
  State<ChatSettingsModal> createState() => _ChatSettingsModalState();
}

class _ChatSettingsModalState extends State<ChatSettingsModal>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _inviteSearchController = TextEditingController();
  
  List<dynamic> _currentMembers = [];
  List<dynamic> _filteredMembers = [];
  List<dynamic> _searchResults = [];
  String _searchQuery = '';
  final bool _isLoading = false;
  bool _isSearchingUsers = false;
  bool _isCreator = false;
  bool _isAdmin = false;
  bool _isLeavingRoom = false;
  bool _isDeletingRoom = false;
  bool _isClearingMessages = false;
  String? _currentUserId;
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
    _inviteSearchController.addListener(_onInviteSearchChanged);
    _loadMembers(); // _checkUserRole() will be called after members are loaded
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _inviteSearchController.removeListener(_onInviteSearchChanged);
    _searchTimer?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    _inviteSearchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      if (_searchQuery.isEmpty) {
        _filteredMembers = List.from(_currentMembers);
      } else {
        _filteredMembers = _currentMembers.where((member) {
          final name = member['name']?.toString().toLowerCase() ?? '';
          final email = member['email']?.toString().toLowerCase() ?? '';
          final query = _searchQuery.toLowerCase();
          return name.contains(query) || email.contains(query);
        }).toList();
      }
    });
  }

  void _onInviteSearchChanged() {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      final query = _inviteSearchController.text.trim();
      if (query.length >= 2) {
        _searchUsers(query);
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    });
  }

  Future<void> _loadMembers() async {
    try {
      final chatDataSource = getIt<ChatRemoteDataSource>();
      final members = await chatDataSource.getChatRoomMembers(widget.roomId);
      
      setState(() {
        _currentMembers = members;
        _filteredMembers = List.from(members);
      });
      
      // Check user role after members are loaded
      _checkUserRole();
    } catch (e) {
      print('Error loading members: $e');
    }
  }

  void _checkUserRole() async {
    try {
      final storage = getIt<SecureStorage>();
      final userData = await storage.getUserData();
      final userId = userData['userId']?.toString();
      
      setState(() {
        _currentUserId = userId;
      });
      
      print('🔍 Current User ID: $userId');
      print('🔍 Current Members: $_currentMembers');
      
      if (userId != null && _currentMembers.isNotEmpty) {
        for (var member in _currentMembers) {
          final memberUserId = member['userId']?.toString();
          print('🔍 Checking member: $memberUserId vs $userId');
          
          if (memberUserId == userId) {
            setState(() {
              _isCreator = member['creator'] == true;
              _isAdmin = member['admin'] == true || member['role'] == 'admin';
            });
            print('🔍 User role found - Creator: $_isCreator, Admin: $_isAdmin');
            break;
          }
        }
      }
    } catch (e) {
      print('Error checking user role: $e');
    }
  }

  Future<void> _leaveRoom() async {
    setState(() {
      _isLeavingRoom = true;
    });

    try {
      final chatDataSource = getIt<ChatRemoteDataSource>();
      await chatDataSource.leaveRoom(widget.roomId);
      
      if (mounted) {
        Navigator.of(context).pop();
        widget.onLeftRoom?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã rời khỏi phòng chat thành công')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi rời phòng: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLeavingRoom = false;
        });
      }
    }
  }

  Future<void> _deleteRoom() async {
    setState(() {
      _isDeletingRoom = true;
    });

    try {
      final chatDataSource = getIt<ChatRemoteDataSource>();
      await chatDataSource.deleteRoom(widget.roomId);
      
      if (mounted) {
        Navigator.of(context).pop();
        widget.onChatDeleted?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa phòng chat thành công')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa phòng: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeletingRoom = false;
        });
      }
    }
  }

  Future<void> _clearAllMessages() async {
    setState(() {
      _isClearingMessages = true;
    });

    try {
      final chatDataSource = getIt<ChatRemoteDataSource>();
      await chatDataSource.clearMessages(widget.roomId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa tất cả tin nhắn thành công')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa tin nhắn: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isClearingMessages = false;
        });
      }
    }
  }

  Future<void> _searchUsers(String query) async {
    if (_isSearchingUsers) return;
    
    setState(() {
      _isSearchingUsers = true;
    });

    try {
      final chatDataSource = getIt<ChatRemoteDataSource>();
      final users = await chatDataSource.searchUsers(query);
      
      // Filter out users who are already members
      final memberIds = _currentMembers.map((m) => m['id']?.toString()).toSet();
      final filteredUsers = users.where((user) => 
        !memberIds.contains(user['id']?.toString())
      ).toList();
      
      setState(() {
        _searchResults = filteredUsers;
      });
    } catch (e) {
      print('Error searching users: $e');
    } finally {
      setState(() {
        _isSearchingUsers = false;
      });
    }
  }

  Future<void> _inviteUser(dynamic user) async {
    try {
      final chatDataSource = getIt<ChatRemoteDataSource>();
      await chatDataSource.addMemberByEmail(widget.roomId, user['email']);
      
      // Add user to members list
      final newMember = {
        ...user,
        'role': 'MEMBER',
      };
      
      setState(() {
        _currentMembers.add(newMember);
        _filteredMembers = List.from(_currentMembers);
        _searchResults.removeWhere((u) => u['id'] == user['id']);
      });
      
      if (widget.onMembersUpdated != null) {
        widget.onMembersUpdated!(_currentMembers);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã mời ${user['username'] ?? user['full_name'] ?? user['name'] ?? 'người dùng'} vào nhóm'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi mời thành viên: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.settings, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.roomName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${_currentMembers.length} thành viên',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // Tab Bar
            Container(
              color: Colors.grey[100],
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.people),
                    text: 'Quản lý thành viên',
                  ),
                  Tab(
                    icon: Icon(Icons.person_add),
                    text: 'Thêm Thành Viên',
                  ),
                  Tab(
                    icon: Icon(Icons.settings),
                    text: 'Hành động',
                  ),
                ],
                labelColor: Colors.blue[600],
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: Colors.blue[600],
              ),
            ),
            
            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMembersTab(),
                  _buildInviteTab(),
                  _buildActionsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersTab() {
    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm thành viên theo tên hoặc email...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        
        // Members list
        Expanded(
          child: ListView.builder(
            itemCount: _filteredMembers.length,
            itemBuilder: (context, index) {
              final member = _filteredMembers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    member['name']?.toString().substring(0, 1).toUpperCase() ?? 'U',
                    style: TextStyle(color: Colors.blue[600]),
                  ),
                ),
                title: Text(member['username']?.toString() ?? member['name']?.toString() ?? 'Unknown'),
                subtitle: Text(member['email']?.toString() ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildRoleBadge(member),
                    if ((_isCreator || _isAdmin) && 
                        member['userId']?.toString() != _currentUserId &&
                        member['creator'] != true &&
                        !(_isAdmin && member['admin'] == true))
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removeMember(member),
                        tooltip: 'Xóa thành viên',
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInviteTab() {
    return Column(
      children: [
        // Search bar for users
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _inviteSearchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm người dùng theo tên hoặc email...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _isSearchingUsers
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _inviteSearchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _inviteSearchController.clear();
                            setState(() {
                              _searchResults = [];
                            });
                          },
                        )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        
        // Search results
        Expanded(
          child: _searchResults.isEmpty
              ? const Center(
                  child: Text(
                    'Nhập tên hoặc email để tìm kiếm người dùng',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[100],
                        child: Text(
                          user['name']?.toString().substring(0, 1).toUpperCase() ?? 'U',
                          style: TextStyle(color: Colors.green[600]),
                        ),
                      ),
                      title: Text(user['name']?.toString() ?? 'Unknown'),
                      subtitle: Text(user['email']?.toString() ?? ''),
                      trailing: ElevatedButton(
                        onPressed: () => _inviteUser(user),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Mời'),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildActionsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hành động',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Leave room action
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.orange),
            title: const Text('Rời khỏi nhóm'),
            subtitle: const Text('Bạn sẽ không thể xem tin nhắn trong nhóm này nữa'),
            trailing: _isLeavingRoom ? const CircularProgressIndicator() : null,
            onTap: _isLeavingRoom ? null : () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Xác nhận rời nhóm'),
                  content: const Text('Bạn có chắc chắn muốn rời khỏi nhóm chat này?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _leaveRoom();
                      },
                      child: const Text('Rời nhóm', style: TextStyle(color: Colors.orange)),
                    ),
                  ],
                ),
              );
            },
          ),
          
          if (_isCreator || _isAdmin) ...[
            const Divider(),
            
            // Clear all messages action
            ListTile(
              leading: const Icon(Icons.clear_all, color: Colors.red),
              title: const Text('Xóa tất cả tin nhắn'),
              subtitle: const Text('Xóa toàn bộ lịch sử tin nhắn trong nhóm'),
              trailing: _isClearingMessages ? const CircularProgressIndicator() : null,
              onTap: _isClearingMessages ? null : () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xác nhận xóa tin nhắn'),
                    content: const Text('Bạn có chắc chắn muốn xóa tất cả tin nhắn trong nhóm này? Hành động này không thể hoàn tác.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _clearAllMessages();
                        },
                        child: const Text('Xóa tất cả', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            // Delete room action
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Xóa nhóm chat'),
              subtitle: const Text('Xóa hoàn toàn nhóm chat này'),
              trailing: _isDeletingRoom ? const CircularProgressIndicator() : null,
              onTap: _isDeletingRoom ? null : () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xác nhận xóa nhóm'),
                    content: const Text('Bạn có chắc chắn muốn xóa nhóm chat này? Hành động này không thể hoàn tác và sẽ xóa toàn bộ dữ liệu.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteRoom();
                        },
                        child: const Text('Xóa nhóm', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }



  Future<void> _removeMember(dynamic member) async {
    try {
      final chatDataSource = getIt<ChatRemoteDataSource>();
      final memberUserId = member['userId']?.toString();
      
      if (memberUserId == null) return;
      
      await chatDataSource.removeMemberFromChatRoom(
        widget.roomId, 
        memberUserId
      );
      
      setState(() {
        _currentMembers.removeWhere((m) => 
          m['userId']?.toString() == memberUserId
        );
        _filteredMembers = List.from(_currentMembers);
      });
      
      if (widget.onMembersUpdated != null) {
        widget.onMembersUpdated!(_currentMembers);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa ${member['username']} khỏi nhóm'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa thành viên: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildRoleBadge(dynamic member) {
    final isCreator = member['creator'] == true;
    final isAdmin = member['admin'] == true;
    
    if (isCreator) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, size: 16, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'Quản trị viên',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else if (isAdmin) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.admin_panel_settings, size: 16, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'Quản trị viên',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Thành viên',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      );
    }
  }
}