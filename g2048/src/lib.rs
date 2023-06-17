
#![no_std]

use gstd::{debug, msg, prelude::*};

static mut MESSAGE_LOG: Vec<String> = vec![];

#[no_mangle]
extern "C" fn handle() {
    let new_msg = String::from_utf8(msg::load_bytes().unwrap()).expect("Invalid message");

    if new_msg == "PING" {
        msg::reply_bytes("PONG", 0).unwrap();
    }

    unsafe { MESSAGE_LOG.push(new_msg) };

    debug!("{:?} total message(s) stored: ", unsafe { MESSAGE_LOG.len() });
}
