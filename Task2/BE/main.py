# Sườn Backend Python cho ứng dụng bán đồ ăn trực tuyến

from flask import Flask, request, jsonify

app = Flask(__name__)

# Bảng User
users = []

# Bảng Loại Món Ăn
categories = []

# Bảng Món Ăn
foods = []

# Bảng Đơn Hàng
orders = []

# Bảng Chi Tiết Đơn Hàng
order_details = []

# Định nghĩa các route mẫu cho từng bảng

# User
@app.route('/users', methods=['GET', 'POST'])
def handle_users():
    if request.method == 'GET':
        return jsonify(users)
    elif request.method == 'POST':
        user = request.json
        users.append(user)
        return jsonify(user), 201

# Loại Món Ăn
@app.route('/categories', methods=['GET', 'POST'])
def handle_categories():
    if request.method == 'GET':
        return jsonify(categories)
    elif request.method == 'POST':
        category = request.json
        categories.append(category)
        return jsonify(category), 201

# Món Ăn
@app.route('/foods', methods=['GET', 'POST'])
def handle_foods():
    if request.method == 'GET':
        return jsonify(foods)
    elif request.method == 'POST':
        food = request.json
        foods.append(food)
        return jsonify(food), 201

# Đơn Hàng
@app.route('/orders', methods=['GET', 'POST'])
def handle_orders():
    if request.method == 'GET':
        return jsonify(orders)
    elif request.method == 'POST':
        order = request.json
        orders.append(order)
        return jsonify(order), 201

# Chi Tiết Đơn Hàng
@app.route('/order_details', methods=['GET', 'POST'])
def handle_order_details():
    if request.method == 'GET':
        return jsonify(order_details)
    elif request.method == 'POST':
        detail = request.json
        order_details.append(detail)
        return jsonify(detail), 201

if __name__ == '__main__':
    app.run(debug=True)
