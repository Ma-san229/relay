-- Enable Row Level Security
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users Profile Table
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  PRIMARY KEY (id)
);

-- Messages Table
CREATE TABLE IF NOT EXISTS messages (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  sender_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  receiver_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Groups Table
CREATE TABLE IF NOT EXISTS groups (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  created_by UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Group Members Table
CREATE TABLE IF NOT EXISTS group_members (
  group_id UUID REFERENCES groups(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  role TEXT CHECK (role IN ('admin', 'member')) NOT NULL DEFAULT 'member',
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  PRIMARY KEY (group_id, user_id)
);

-- Row Level Security Policies
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE group_members ENABLE ROW LEVEL SECURITY;

-- Profiles Policies
CREATE POLICY "Public profiles are viewable by everyone" ON profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can update their own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Messages Policies
CREATE POLICY "Users can view messages they sent or received" ON messages
  FOR SELECT USING (
    auth.uid() = sender_id OR 
    auth.uid() = receiver_id
  );

CREATE POLICY "Users can insert messages" ON messages
  FOR INSERT WITH CHECK (auth.uid() = sender_id);

-- Groups Policies
CREATE POLICY "Public groups are viewable by everyone" ON groups
  FOR SELECT USING (true);

CREATE POLICY "Group creators can update their groups" ON groups
  FOR UPDATE USING (auth.uid() = created_by);

CREATE POLICY "Users can create groups" ON groups
  FOR INSERT WITH CHECK (auth.uid() = created_by);

-- Group Members Policies
CREATE POLICY "Group members are viewable by group members" ON group_members
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM group_members gm 
      WHERE gm.group_id = group_members.group_id 
      AND gm.user_id = auth.uid()
    )
  );

CREATE POLICY "Group admins can manage members" ON group_members
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM group_members gm 
      WHERE gm.group_id = group_members.group_id 
      AND gm.user_id = auth.uid() 
      AND gm.role = 'admin'
    )
  );

-- Functions and Triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc'::text, NOW());
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_messages_updated_at
  BEFORE UPDATE ON messages
  FOR EACH ROW
  EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_groups_updated_at
  BEFORE UPDATE ON groups
  FOR EACH ROW
  EXECUTE PROCEDURE update_updated_at_column();