#![no_std]

use gstd::{debug, msg, prelude::*};
use gstd::contract::Contract;

static mut GAME_BOARD: [[u16; 4]; 4] = [[0; 4]; 4];
static mut SCORE: u32 = 0;

#[no_mangle]
extern "C" fn handle() {
    let new_msg = String::from_utf8(msg::load_bytes().unwrap()).expect("Invalid message");

    match new_msg.as_str() {
        "PING" => {
            msg::reply_bytes("PONG", 0).unwrap();
        }
        "RESET" => {
            unsafe {
                reset_game();
            }
        }
        "LEFT" | "RIGHT" | "UP" | "DOWN" => {
            unsafe {
                let direction = new_msg.as_str();
                move_tiles(direction);
            }
        }
        _ => {
            debug!("Invalid command");
        }
    }

    debug!("Game Board: {:?}", unsafe { GAME_BOARD });
    debug!("Score: {:?}", unsafe { SCORE });
}

fn reset_game() {
    unsafe {
        GAME_BOARD = [[0; 4]; 4];
        SCORE = 0;
    }
}

fn move_tiles(direction: &str) {
    let mut moved = false;
    match direction {
        "LEFT" => {
            for row in 0..4 {
                for col in 1..4 {
                    moved |= merge_tiles(row, col, 0, -1);
                }
            }
        }
        "RIGHT" => {
            for row in 0..4 {
                for col in (0..3).rev() {
                    moved |= merge_tiles(row, col, 0, 1);
                }
            }
        }
        "UP" => {
            for col in 0..4 {
                for row in 1..4 {
                    moved |= merge_tiles(row, col, -1, 0);
                }
            }
        }
        "DOWN" => {
            for col in 0..4 {
                for row in (0..3).rev() {
                    moved |= merge_tiles(row, col, 1, 0);
                }
            }
        }
        _ => {
            debug!("Invalid direction");
            return;
        }
    }

    if moved {
        unsafe {
            generate_random_tile();
        }
    }
}

fn merge_tiles(row: usize, col: usize, row_offset: i32, col_offset: i32) -> bool {
    unsafe {
        let mut moved = false;

        let mut current_row = row as i32;
        let mut current_col = col as i32;

        let value = GAME_BOARD[row][col];

        if value == 0 {
            return moved;
        }

        while is_valid_position(current_row + row_offset, current_col + col_offset) {
            let next_row = (current_row + row_offset) as usize;
            let next_col = (current_col + col_offset) as usize;
            let next_value = GAME_BOARD[next_row][next_col];

            if next_value == 0 {
                GAME_BOARD[next_row][next_col] = value;
                GAME_BOARD[current_row as usize][current_col as usize] = 0;
                current_row += row_offset;
                current_col += col_offset;
                moved = true;
            } else if next_value == value {
                GAME_BOARD[next_row][next_col] = value * 2;
                GAME_BOARD[current_row as usize][current_col as usize] = 0;
                SCORE += value as u32;
                moved = true;
                break;
            } else {
                break;
            }
        }

        moved
    }
}

fn is_valid_position(row: i32, col: i32) -> bool {
    row >= 0 && row < 4 && col >= 0 && col < 4
}

fn generate_random_tile() {
    unsafe {
        let mut empty_positions = vec![];

        for row in 0..4 {
            for col in 0..4 {
                if GAME_BOARD[row][col] == 0 {
                    empty_positions.push((row, col));
                }
            }
        }

        if empty_positions.is_empty() {
            return;
        }

        let random_index = gstd::math::random_range(0, empty_positions.len());
        let (row, col) = empty_positions[random_index];
        let value = if gstd::math::random_range(0, 10) < 9 { 2 } else { 4 };

        GAME_BOARD[row][col] = value;
    }
}


// #![no_std]

// use gstd::{debug, msg, prelude::*};

// static mut MESSAGE_LOG: Vec<String> = vec![];

// #[no_mangle]
// extern "C" fn handle() {
//     let new_msg = String::from_utf8(msg::load_bytes().unwrap()).expect("Invalid message");

//     if new_msg == "PING" {
//         msg::reply_bytes("PONG", 0).unwrap();
//     }

//     unsafe { MESSAGE_LOG.push(new_msg) };

//     debug!("{:?} total message(s) stored: ", unsafe { MESSAGE_LOG.len() });
// }
