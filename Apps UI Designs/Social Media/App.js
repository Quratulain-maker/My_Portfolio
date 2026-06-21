import React, { useState } from 'react';
import { StyleSheet, View, Text, FlatList, TextInput, TouchableOpacity, Image, ScrollView } from 'react-native';

const initialPosts = [
  {
    id: '1',
    username: 'user1',
    content: 'This is my first post!',
    likes: 10,
    comments: ['Great post!', 'Keep it up!'],
    profilePic: 'https://via.placeholder.com/150',
  },
  {
    id: '2',
    username: 'user2',
    content: 'Enjoying the weekend!',
    likes: 15,
    comments: ['Have fun!', 'Looks amazing!'],
    profilePic: 'https://via.placeholder.com/150',
  },
];

export default function App() {
  const [posts, setPosts] = useState(initialPosts);
  const [newPostContent, setNewPostContent] = useState('');
  const [selectedPost, setSelectedPost] = useState(null);

  const addPost = () => {
    if (newPostContent.trim()) {
      const newPost = {
        id: Math.random().toString(),
        username: 'currentUser',
        content: newPostContent,
        likes: 0,
        comments: [],
        profilePic: 'https://via.placeholder.com/150',
      };
      setPosts([newPost, ...posts]);
      setNewPostContent('');
    }
  };

  const likePost = (postId) => {
    setPosts(
      posts.map((post) =>
        post.id === postId ? { ...post, likes: post.likes + 1 } : post
      )
    );
  };

  const addComment = (postId, comment) => {
    setPosts(
      posts.map((post) =>
        post.id === postId
          ? { ...post, comments: [...post.comments, comment] }
          : post
      )
    );
  };

  const renderPost = ({ item }) => (
    <View style={styles.post}>
      <View style={styles.postHeader}>
        <Image source={{ uri: item.profilePic }} style={styles.profilePic} />
        <Text style={styles.username}>{item.username}</Text>
      </View>
      <Text style={styles.postContent}>{item.content}</Text>
      <View style={styles.postFooter}>
        <TouchableOpacity onPress={() => likePost(item.id)}>
          <Text style={styles.likeButton}>{item.likes} Likes</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={() => setSelectedPost(item)}>
          <Text style={styles.commentButton}>{item.comments.length} Comments</Text>
        </TouchableOpacity>
      </View>
    </View>
  );

  const renderComment = ({ item }) => (
    <View style={styles.comment}>
      <Text style={styles.commentText}>{item}</Text>
    </View>
  );

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerText}>Social Media App</Text>
      </View>
      <View style={styles.newPostContainer}>
        <TextInput
          style={styles.newPostInput}
          placeholder="What's on your mind?"
          value={newPostContent}
          onChangeText={setNewPostContent}
          multiline
        />
        <TouchableOpacity style={styles.postButton} onPress={addPost}>
          <Text style={styles.postButtonText}>Post</Text>
        </TouchableOpacity>
      </View>
      <FlatList
        data={posts}
        renderItem={renderPost}
        keyExtractor={(item) => item.id}
        style={styles.feed}
      />
      {selectedPost && (
        <View style={styles.commentModal}>
          <Text style={styles.commentHeader}>Comments</Text>
          <FlatList
            data={selectedPost.comments}
            renderItem={renderComment}
            keyExtractor={(item, index) => index.toString()}
          />
          <TextInput
            style={styles.commentInput}
            placeholder="Add a comment..."
            onSubmitEditing={(e) => {
              addComment(selectedPost.id, e.nativeEvent.text);
              e.nativeEvent.text = '';
            }}
          />
          <TouchableOpacity
            style={styles.closeButton}
            onPress={() => setSelectedPost(null)}
          >
            <Text style={styles.closeButtonText}>Close</Text>
          </TouchableOpacity>
        </View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F7F7F7',
  },
  header: {
    padding: 16,
    backgroundColor: '#007BFF',
    alignItems: 'center',
  },
  headerText: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#FFF',
  },
  newPostContainer: {
    padding: 16,
    backgroundColor: '#FFF',
    borderBottomWidth: 1,
    borderBottomColor: '#EEE',
  },
  newPostInput: {
    height: 80,
    borderColor: '#CCC',
    borderWidth: 1,
    borderRadius: 8,
    padding: 8,
    marginBottom: 8,
  },
  postButton: {
    backgroundColor: '#007BFF',
    borderRadius: 8,
    padding: 12,
    alignItems: 'center',
  },
  postButtonText: {
    color: '#FFF',
    fontSize: 16,
    fontWeight: 'bold',
  },
  feed: {
    flex: 1,
    padding: 16,
  },
  post: {
    backgroundColor: '#FFF',
    borderRadius: 8,
    padding: 16,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  postHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  profilePic: {
    width: 40,
    height: 40,
    borderRadius: 20,
    marginRight: 8,
  },
  username: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
  },
  postContent: {
    fontSize: 14,
    color: '#333',
    marginBottom: 8,
  },
  postFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  likeButton: {
    fontSize: 14,
    color: '#007BFF',
  },
  commentButton: {
    fontSize: 14,
    color: '#007BFF',
  },
  commentModal: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: '#FFF',
    padding: 16,
  },
  commentHeader: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 16,
    color: '#333',
  },
  comment: {
    padding: 8,
    borderBottomWidth: 1,
    borderBottomColor: '#EEE',
  },
  commentText: {
    fontSize: 14,
    color: '#333',
  },
  commentInput: {
    height: 40,
    borderColor: '#CCC',
    borderWidth: 1,
    borderRadius: 8,
    padding: 8,
    marginTop: 16,
  },
  closeButton: {
    backgroundColor: '#007BFF',
    borderRadius: 8,
    padding: 12,
    alignItems: 'center',
    marginTop: 16,
  },
  closeButtonText: {
    color: '#FFF',
    fontSize: 16,
    fontWeight: 'bold',
  },
});

