import React, { useState } from 'react';
import { StyleSheet, View, Text, FlatList, TouchableOpacity, Image, ScrollView } from 'react-native';

const restaurants = [
  {
    id: '1',
    name: 'Burger Palace',
    image: 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?ixlib=rb-1.2.1&auto=format&fit=crop&w=1352&q=80',
    menu: [
      { id: '1', name: 'Classic Burger', price: 8.99 },
      { id: '2', name: 'Cheese Burger', price: 9.99 },
      { id: '3', name: 'Bacon Burger', price: 10.99 },
    ],
  },
  {
    id: '2',
    name: 'Pizza Haven',
    image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtqGYBjPUyQhbpLxdgtFHqOYZOvOh6cGDj1A&s',
    
    menu: [
      { id: '4', name: 'Margherita Pizza', price: 12.99 },
      { id: '5', name: 'Pepperoni Pizza', price: 14.99 },
      { id: '6', name: 'Veggie Pizza', price: 13.99 },
    ],
  },
  {
    id: '3',
    name: 'Sushi World',
    image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSQcnA7fJgYgMKmB9R-AXcYSVkI0xVFF4qHXA&s',
    menu: [
      { id: '7', name: 'California Roll', price: 6.99 },
      { id: '8', name: 'Spicy Tuna Roll', price: 8.99 },
      { id: '9', name: 'Dragon Roll', price: 10.99 },
    ],
  },
];

export default function App() {
  const [selectedRestaurant, setSelectedRestaurant] = useState(null);
  const [cart, setCart] = useState([]);

  const addToCart = (item) => {
    setCart([...cart, item]);
  };

  const removeFromCart = (itemId) => {
    setCart(cart.filter((item) => item.id !== itemId));
  };

  const getTotal = () => {
    return cart.reduce((total, item) => total + item.price, 0).toFixed(2);
  };

  const renderRestaurant = ({ item }) => (
    <TouchableOpacity
      style={styles.restaurantCard}
      onPress={() => setSelectedRestaurant(item)}
    >
      <Image source={{ uri: item.image }} style={styles.restaurantImage} />
      <Text style={styles.restaurantName}>{item.name}</Text>
    </TouchableOpacity>
  );

  const renderMenuItem = ({ item }) => (
    <View style={styles.menuItem}>
      <Text style={styles.menuItemName}>{item.name}</Text>
      <Text style={styles.menuItemPrice}>${item.price.toFixed(2)}</Text>
      <TouchableOpacity style={styles.addButton} onPress={() => addToCart(item)}>
        <Text style={styles.addButtonText}>Add to Cart</Text>
      </TouchableOpacity>
    </View>
  );

  const renderCartItem = ({ item }) => (
    <View style={styles.cartItem}>
      <Text style={styles.cartItemName}>{item.name}</Text>
      <Text style={styles.cartItemPrice}>${item.price.toFixed(2)}</Text>
      <TouchableOpacity style={styles.removeButton} onPress={() => removeFromCart(item.id)}>
        <Text style={styles.removeButtonText}>Remove</Text>
      </TouchableOpacity>
    </View>
  );

  return (
    <View style={styles.container}>
      {!selectedRestaurant ? (
        <>
          <Text style={styles.header}>Restaurants</Text>
          <FlatList
            data={restaurants}
            renderItem={renderRestaurant}
            keyExtractor={(item) => item.id}
          />
        </>
      ) : (
        <>
          <TouchableOpacity style={styles.backButton} onPress={() => setSelectedRestaurant(null)}>
            <Text style={styles.backButtonText}>← Back to Restaurants</Text>
          </TouchableOpacity>
          <Text style={styles.header}>{selectedRestaurant.name}</Text>
          <FlatList
            data={selectedRestaurant.menu}
            renderItem={renderMenuItem}
            keyExtractor={(item) => item.id}
          />
        </>
      )}
      {cart.length > 0 && (
        <View style={styles.cartContainer}>
          <Text style={styles.cartHeader}>Your Cart</Text>
          <FlatList
            data={cart}
            renderItem={renderCartItem}
            keyExtractor={(item) => item.id}
          />
          <Text style={styles.totalText}>Total: ${getTotal()}</Text>
          <TouchableOpacity style={styles.checkoutButton}>
            <Text style={styles.checkoutButtonText}>Checkout</Text>
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
    padding: 16,
  },
  header: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 16,
    color: '#333',
  },
  restaurantCard: {
    backgroundColor: '#FFF',
    borderRadius: 12,
    marginBottom: 16,
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  restaurantImage: {
    width: '100%',
    height: 150,
  },
  restaurantName: {
    fontSize: 18,
    fontWeight: 'bold',
    padding: 16,
    color: '#333',
  },
  backButton: {
    marginBottom: 16,
  },
  backButtonText: {
    fontSize: 16,
    color: '#007BFF',
  },
  menuItem: {
    backgroundColor: '#FFF',
    borderRadius: 12,
    padding: 16,
    marginBottom: 8,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  menuItemName: {
    fontSize: 16,
    color: '#333',
  },
  menuItemPrice: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
  },
  addButton: {
    backgroundColor: '#007BFF',
    borderRadius: 8,
    paddingVertical: 8,
    paddingHorizontal: 12,
  },
  addButtonText: {
    color: '#FFF',
    fontSize: 14,
    fontWeight: 'bold',
  },
  cartContainer: {
    backgroundColor: '#FFF',
    borderRadius: 12,
    padding: 16,
    marginTop: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  cartHeader: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 16,
    color: '#333',
  },
  cartItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  cartItemName: {
    fontSize: 16,
    color: '#333',
  },
  cartItemPrice: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
  },
  removeButton: {
    backgroundColor: '#FF3B30',
    borderRadius: 8,
    paddingVertical: 4,
    paddingHorizontal: 8,
  },
  removeButtonText: {
    color: '#FFF',
    fontSize: 14,
    fontWeight: 'bold',
  },
  totalText: {
    fontSize: 18,
    fontWeight: 'bold',
    marginTop: 16,
    color: '#333',
    textAlign: 'center',
  },
  checkoutButton: {
    backgroundColor: '#007BFF',
    borderRadius: 12,
    paddingVertical: 12,
    marginTop: 16,
    alignItems: 'center',
  },
  checkoutButtonText: {
    color: '#FFF',
    fontSize: 16,
    fontWeight: 'bold',
  },
});
