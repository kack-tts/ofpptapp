<?php
// crud_auth.php
header('Content-Type: application/json');
require 'connection.php';

// Read the HTTP method and input data
$method = $_SERVER['REQUEST_METHOD'];
$input = json_decode(file_get_contents('php://input'), true);

switch ($method) {
    case 'GET':
        // Get all users or a single user by id
        if (isset($_GET['id'])) {
            $id = intval($_GET['id']);
            $stmt = $pdo->prepare("SELECT id, username, email, role, created_at, updated_at FROM auth WHERE id = ?");
            $stmt->execute([$id]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
            if ($user) {
                echo json_encode($user);
            } else {
                http_response_code(404);
                echo json_encode(['error' => 'User not found']);
            }
        } else {
            $stmt = $pdo->query("SELECT id, username, email, role, created_at, updated_at FROM auth");
            $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode($users);
        }
        break;

    case 'POST':
        // Create a new user
        if (!isset($input['username'], $input['email'], $input['password'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing required fields']);
            exit;
        }

        // Hash the password before storing
        $hashedPassword = password_hash($input['password'], PASSWORD_DEFAULT);

        // Optional fields
        $role = isset($input['role']) ? $input['role'] : 'user';
        $pin = isset($input['pin']) ? $input['pin'] : null;

        try {
            $stmt = $pdo->prepare("INSERT INTO auth (username, email, password, pin, role) VALUES (?, ?, ?, ?, ?)");
            $stmt->execute([$input['username'], $input['email'], $hashedPassword, $pin, $role]);
            echo json_encode(['message' => 'User created', 'id' => $pdo->lastInsertId()]);
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Failed to create user: ' . $e->getMessage()]);
        }
        break;

    case 'PUT':
        // Update an existing user (by id)
        if (!isset($_GET['id'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing user id']);
            exit;
        }
        $id = intval($_GET['id']);

        // Prepare fields for update
        $fields = [];
        $values = [];

        if (isset($input['username'])) {
            $fields[] = "username = ?";
            $values[] = $input['username'];
        }
        if (isset($input['email'])) {
            $fields[] = "email = ?";
            $values[] = $input['email'];
        }
        if (isset($input['password'])) {
            $fields[] = "password = ?";
            $values[] = password_hash($input['password'], PASSWORD_DEFAULT);
        }
        if (isset($input['pin'])) {
            $fields[] = "pin = ?";
            $values[] = $input['pin'];
        }
        if (isset($input['role'])) {
            $fields[] = "role = ?";
            $values[] = $input['role'];
        }

        if (count($fields) === 0) {
            http_response_code(400);
            echo json_encode(['error' => 'No data provided for update']);
            exit;
        }

        $values[] = $id;
        $sql = "UPDATE auth SET " . implode(", ", $fields) . " WHERE id = ?";

        try {
            $stmt = $pdo->prepare($sql);
            $stmt->execute($values);
            echo json_encode(['message' => 'User updated']);
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Failed to update user: ' . $e->getMessage()]);
        }
        break;

    case 'DELETE':
        // Delete user by id
        if (!isset($_GET['id'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing user id']);
            exit;
        }
        $id = intval($_GET['id']);

        try {
            $stmt = $pdo->prepare("DELETE FROM auth WHERE id = ?");
            $stmt->execute([$id]);
            if ($stmt->rowCount()) {
                echo json_encode(['message' => 'User deleted']);
            } else {
                http_response_code(404);
                echo json_encode(['error' => 'User not found']);
            }
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Failed to delete user: ' . $e->getMessage()]);
        }
        break;

    default:
        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
        break;
}
?>

