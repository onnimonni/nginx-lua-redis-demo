<?php
/**
 * Simple redis data saving service to GET/SET/DELETE data from redis
 */

$redis = new Redis(); 
$redis->connect('redis', 6379);

$request_path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

switch($_SERVER['REQUEST_METHOD'])
{
	case 'GET': 
		echo $redis->get( $request_path );
	break;

	case 'POST':
		$content = file_get_contents("php://input");
		json_decode($content);

 		if (json_last_error() != JSON_ERROR_NONE) {
 			http_response_code(422);
 			echo json_encode( [ 'result' => 'ERROR', 'info' => 'Input is not valid JSON.' ] ); 
 		} elseif ($content) {
 			
 			# Minify JSON
 			$content = json_encode(json_decode($content));

			if ( $redis->set( $request_path, $content ) == '1') {
				http_response_code(200);
				echo json_encode( [ 'result' => 'OK', 'info' => 'Data saved.' ] );
			}
		}
	break;

	case 'DELETE':
		$result = $redis->delete( $request_path );
		if ( $result == '1') {
			http_response_code(200);
			echo json_encode( [ 'result' => 'OK', 'info' => 'Data deleted.' ] );
		} elseif ( $result == '0') {
			http_response_code(404);
			echo json_encode( [ 'result' => 'NOT_FOUND', 'info' => 'Data doesn\'t exist' ] );
		}
	break;

	default:
		http_response_code(405);
		echo json_encode( [ 'result' => 'ERROR', 'info' => 'Only GET/POST/DELETE methods are supported.' ] ); 
	break;
}