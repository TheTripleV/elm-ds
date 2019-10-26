use serde::{Serialize, Deserialize};
use ds::Mode as DsMode;

#[derive(Serialize, Deserialize, Debug)]
#[serde(tag = "type")]
pub enum Message {
    UpdateTeamNumber {
        team_number: u32,
    },
    UpdateMode {
        mode: Mode
    },
    UpdateEnableStatus {
        enabled: bool
    },
    JoystickUpdate {
        removed: bool,
        name: String,
    },
    UpdateJoystickMapping {
        name: String,
        pos: usize
    },
    RobotStateUpdate {
        comms_alive: bool,
        code_alive: bool,
        joysticks: bool,
        voltage: f32,
    },
    NewStdout {
        message: String,
    },
    InitStdout {
        contents: Vec<String>
    },
    EstopRobot
}

#[derive(Serialize, Deserialize, Copy, Clone, Debug)]
pub enum Mode {
    Autonomous,
    Teleoperated,
    Test,
}

impl Mode {
    pub fn from_ds(mode: DsMode) -> Mode {
        match mode {
            DsMode::Autonomous => Mode::Autonomous,
            DsMode::Teleoperated => Mode::Teleoperated,
            DsMode::Test => Mode::Test
        }
    }

    pub fn to_ds(self) -> DsMode {
        match self {
            Mode::Autonomous => DsMode::Autonomous,
            Mode::Teleoperated => DsMode::Teleoperated,
            Mode::Test => DsMode::Test
        }
    }
}