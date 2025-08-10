<?php
// database/seeders/DatabaseSeeder.php
namespace Database\Seeders;

use App\Models\User;
use App\Models\Room;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run()
    {
        // Admin user
        $admin = User::create([
            'name' => 'Admin Demo',
            'username' => 'admin',
            'email' => 'admin@demo.com',
            'password' => Hash::make('123456'),
            'role' => 'admin',
        ]);

        // Parent user
        $parent = User::create([
            'name' => 'Parent Demo',
            'username' => 'parent',
            'email' => 'parent@demo.com',
            'password' => Hash::make('123456'),
            'role' => 'parent',
        ]);

        // Caretaker user
        $caretaker = User::create([
            'name' => 'Caretaker Demo',
            'username' => 'caretaker',
            'email' => 'caretaker@demo.com',
            'password' => Hash::make('123456'),
            'role' => 'caretaker',
        ]);

        // Additional users untuk testing
        $parent2 = User::create([
            'name' => 'Sarah Johnson',
            'username' => 'sarah',
            'email' => 'sarah@demo.com',
            'password' => Hash::make('123456'),
            'role' => 'parent',
        ]);

        $caretaker2 = User::create([
            'name' => 'Maria Garcia',
            'username' => 'maria',
            'email' => 'maria@demo.com',
            'password' => Hash::make('123456'),
            'role' => 'caretaker',
        ]);

        // Sample rooms
        $room1 = Room::create([
            'name' => 'Kamar Bayi A',
            'description' => 'Kamar bayi lantai 1',
            'parent_id' => $parent->id,
        ]);

        $room2 = Room::create([
            'name' => 'Kamar Bayi B',
            'description' => 'Kamar bayi lantai 2',
            'parent_id' => $parent->id,
        ]);

        $room3 = Room::create([
            'name' => 'Nursery Room',
            'description' => 'Main nursery with monitoring system',
            'parent_id' => $parent2->id,
        ]);

        // Assign caretakers to rooms
        $caretaker->rooms()->attach([$room1->id, $room2->id]);
        $caretaker2->rooms()->attach([$room2->id, $room3->id]);

        echo "✅ Seeded users:\n";
        echo "Admin: admin@demo.com / admin (password: 123456)\n";
        echo "Parent: parent@demo.com / parent (password: 123456)\n";
        echo "Caretaker: caretaker@demo.com / caretaker (password: 123456)\n";
        echo "Sarah: sarah@demo.com / sarah (password: 123456)\n";
        echo "Maria: maria@demo.com / maria (password: 123456)\n";
    }
}